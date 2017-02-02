//
//  TPerfectHTTPServer.swift
//  TPerfectHTTPServer
//
//  Created by Christopher Simpson on 10/28/16.
//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Thrift
import Foundation
import PerfectRequestLogger
import PerfectLogger

open class TPerfectHTTPServer<InProtocol: TProtocol, OutProtocol: TProtocol, Processor: TProcessor, Service> where Processor.Service == Service {
  
  var serviceHandler: Service
  var server: HTTPServer.Server? = nil

  public init(name: String = "", address: String = "localhost", path: String = "", port: Int = 9090,
              service: Service, inProtocol: InProtocol.Type, outProtocol: OutProtocol.Type?=nil, processor: Processor.Type) throws {
    
    self.serviceHandler = service
    // setup route
    let route = Route(method: .post, uri: "/\(path)", handler: { request, response in
      // logging helper
      func log() {
        let msgTuple = try? InProtocol(on: request.readTransport()).readMessageBegin()
        LogFile.info("\(Date()) [\(msgTuple?.0 ?? "unknown")] from \(request.remoteAddress.host)")
      }
      
      // set header
      response.setHeader(.contentType, value: "application/x-thrift")
      
      // create protocols
      let inProtocol = InProtocol(on: request.readTransport())
      let outTransport = response.writeTransport()
      let outProtocol = OutProtocol(on: outTransport)
      log()
      
      do {
        let proc = Processor(service: self.serviceHandler)
        try proc.process(on: inProtocol, outProtocol: outProtocol)
        try outTransport.flush() // sets response status/body
        response.completed()
      } catch {
        response.status = .badRequest
        response.completed()
      }
    })
    
    // serve it
    server = HTTPServer.Server(name: name,
                               address: address,
                               port: port,
                               routes: Routes([route]),
                               requestFilters: [(RequestLogger(), HTTPFilterPriority.high)],
                               responseFilters: [(RequestLogger(), HTTPFilterPriority.low)])

    
  }
  
  public func serve() throws {
    if let server = server {
      try HTTPServer.launch([server])
    }
  }
}

// Mark: Request/Response transport helpers

extension HTTPRequest {
  func readTransport() -> TMemoryBufferTransport {
    let t = TMemoryBufferTransport()
    if let data = self.postBodyBytes {
      t.reset(readBuffer: Data(bytes: data))
    }
    return t
  }
}

extension HTTPResponse {
  func writeTransport() -> TMemoryBufferTransport {
    let t = TMemoryBufferTransport(flushHandler: { trans, buff in
      let array = buff.withUnsafeBytes {
        Array<UInt8>(UnsafeBufferPointer(start: $0, count: buff.count))
      }
      self.status = .ok
      self.setBody(bytes: array)
    })
    return t
  }
}
