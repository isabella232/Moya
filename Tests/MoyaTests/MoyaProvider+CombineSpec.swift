#if canImport(Combine)
import Quick
import Nimble
import Combine

#if canImport(OHHTTPStubs)
import OHHTTPStubs
#elseif canImport(OHHTTPStubsSwift)
import OHHTTPStubsCore
import OHHTTPStubsSwift
#endif

@testable import Moya

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class MoyaProviderCombineSpec: QuickSpec {
    override func spec() {
        describe("provider") {
            var provider: MoyaProvider<GitHub>!

            beforeEach {
                provider = MoyaProvider<GitHub>(stubClosure: MoyaProvider.immediatelyStub)
            }

            it("emits one Response object") {
                var calls = 0

                _ = provider.combine.request(.zen)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case let .failure(error):
                            fail("errored: \(error)")
                        default:
                            ()
                        }
                    }, receiveValue: { _ in
                        calls += 1
                    })

                expect(calls).to(equal(1))
            }

            it("emits stubbed data for zen request") {
                var responseData: Data?

                let target: GitHub = .zen
                _ = provider.combine.request(target)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case let .failure(error):
                            fail("errored: \(error)")
                        default:
                            ()
                        }
                    }, receiveValue: { response in
                        responseData = response.data
                    })

                expect(responseData).to(equal(target.sampleData))
            }

//            it("maps JSON data correctly for user profile request") {
//                var receivedResponse: [String: Any]?
//
//                let target: GitHub = .userProfile("ashfurrow")
//                _ = provider.combine.request(target).mapJSON().subscribe(onNext: { response in
//                    receivedResponse = response as? [String: Any]
//                })
//
//                expect(receivedResponse).toNot(beNil())
//            }
        }

//        describe("failing") {
//            var provider: MoyaProvider<GitHub>!
//
//            beforeEach {
//                provider = MoyaProvider<GitHub>(endpointClosure: failureEndpointClosure, stubClosure: MoyaProvider.immediatelyStub)
//            }
//
//            it("emits the correct error message") {
//                var receivedError: MoyaError?
//
//                _ = provider.rx.request(.zen).subscribe { event in
//                    switch event {
//                    case .success:          fail("should have errored")
//                    case .error(let error): receivedError = error as? MoyaError
//                    }
//                }
//
//                switch receivedError {
//                case .some(.underlying(let error, _)):
//                    expect(error.localizedDescription) == "Houston, we have a problem"
//                default:
//                    fail("expected an Underlying error that Houston has a problem")
//                }
//            }
//
//            it("emits an error") {
//                var errored = false
//
//                let target: GitHub = .zen
//                _ = provider.rx.request(target).subscribe { event in
//                    switch event {
//                    case .success:  fail("we should have errored")
//                    case .error:    errored = true
//                    }
//                }
//
//                expect(errored).to(beTrue())
//            }
//        }
//
//        describe("a reactive provider") {
//            var provider: MoyaProvider<GitHub>!
//
//            beforeEach {
//                OHHTTPStubs.stubRequests(passingTest: {$0.url!.path == "/zen"}, withStubResponse: { _ in
//                    return OHHTTPStubsResponse(data: GitHub.zen.sampleData, statusCode: 200, headers: nil)
//                })
//                provider = MoyaProvider<GitHub>(trackInflights: true)
//            }
//
//            it("emits identical response for inflight requests") {
//                let target: GitHub = .zen
//                let signalProducer1 = provider.rx.request(target)
//                let signalProducer2 = provider.rx.request(target)
//
//                expect(provider.inflightRequests.keys.count).to(equal(0))
//
//                var receivedResponse: Moya.Response!
//
//                _ = signalProducer1.subscribe { event in
//                    switch event {
//                    case .success(let response):
//                        receivedResponse = response
//                        expect(provider.inflightRequests.count).to(equal(1))
//
//                    case .error(let error):
//                        fail("errored: \(error)")
//                    }
//                }
//
//                _ = signalProducer2.subscribe { event in
//                    switch event {
//                    case .success(let response):
//                        expect(receivedResponse).toNot(beNil())
//                        expect(receivedResponse).to(beIdenticalToResponse(response))
//                        expect(provider.inflightRequests.count).to(equal(1))
//
//                    case .error(let error):
//                        fail("errored: \(error)")
//                    }
//                }
//
//                // Allow for network request to complete
//                expect(provider.inflightRequests.count).toEventually(equal(0))
//            }
//        }
//
//        describe("a provider with progress tracking") {
//            var provider: MoyaProvider<GitHubUserContent>!
//            beforeEach {
//                //delete downloaded filed before each test
//                let directoryURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
//                let file = directoryURLs.first!.appendingPathComponent("logo_github.png")
//                try? FileManager.default.removeItem(at: file)
//
//                //`responseTime(-4)` equals to 1000 bytes at a time. The sample data is 4000 bytes.
//                OHHTTPStubs.stubRequests(passingTest: {$0.url!.path.hasSuffix("logo_github.png")}, withStubResponse: { _ in
//                    return OHHTTPStubsResponse(data: GitHubUserContent.downloadMoyaWebContent("logo_github.png").sampleData, statusCode: 200, headers: nil).responseTime(-4)
//                })
//                provider = MoyaProvider<GitHubUserContent>()
//            }
//
//            it("tracks progress of request") {
//                let target: GitHubUserContent = .downloadMoyaWebContent("logo_github.png")
//
//                let expectedNextProgressValues = [0.25, 0.5, 0.75, 1.0, 1.0]
//                let expectedNextResponseCount = 1
//                let expectedErrorEventsCount = 0
//                let expectedCompletedEventsCount = 1
//                let timeout = 5.0
//
//                var nextProgressValues: [Double] = []
//                var nextResponseCount = 0
//                var errorEventsCount = 0
//                var completedEventsCount = 0
//
//                _ = provider.rx.requestWithProgress(target)
//                    .subscribe({ event in
//                        switch event {
//                        case let .next(element):
//                            nextProgressValues.append(element.progress)
//
//                            if element.response != nil { nextResponseCount += 1 }
//                        case .error: errorEventsCount += 1
//                        case .completed: completedEventsCount += 1
//                        }
//                    })
//
//                expect(completedEventsCount).toEventually(equal(expectedCompletedEventsCount), timeout: timeout)
//                expect(errorEventsCount).toEventually(equal(expectedErrorEventsCount), timeout: timeout)
//                expect(nextResponseCount).toEventually(equal(expectedNextResponseCount), timeout: timeout)
//                expect(nextProgressValues).toEventually(equal(expectedNextProgressValues), timeout: timeout)
//            }
//
//            describe("a custom callback queue") {
//                var stubDescriptor: OHHTTPStubsDescriptor!
//
//                beforeEach {
//                    stubDescriptor = OHHTTPStubs.stubRequests(passingTest: {$0.url!.path == "/zen"}, withStubResponse: { _ in
//                        return OHHTTPStubsResponse(data: GitHub.zen.sampleData, statusCode: 200, headers: nil)
//                    })
//                }
//
//                afterEach {
//                    OHHTTPStubs.removeStub(stubDescriptor)
//                }
//
//                describe("a provider with a predefined callback queue") {
//                    var provider: MoyaProvider<GitHub>!
//                    var callbackQueue: DispatchQueue!
//                    var disposeBag: DisposeBag!
//
//                    beforeEach {
//                        disposeBag = DisposeBag()
//
//                        callbackQueue = DispatchQueue(label: UUID().uuidString)
//                        provider = MoyaProvider<GitHub>(callbackQueue: callbackQueue)
//                    }
//
//                    context("the callback queue is provided with the request") {
//                        it("invokes the callback on the request queue") {
//                            let requestQueue = DispatchQueue(label: UUID().uuidString)
//                            var callbackQueueLabel: String?
//
//                            waitUntil(action: { completion in
//                                provider.rx.request(.zen, callbackQueue: requestQueue)
//                                    .subscribe(onSuccess: { _ in
//                                        callbackQueueLabel = DispatchQueue.currentLabel
//                                        completion()
//                                    }).disposed(by: disposeBag)
//                            })
//
//                            expect(callbackQueueLabel) == requestQueue.label
//                        }
//                    }
//
//                    context("the queueless request method is invoked") {
//                        it("invokes the callback on the provider queue") {
//                            var callbackQueueLabel: String?
//
//                            waitUntil(action: { completion in
//                                provider.rx.request(.zen)
//                                    .subscribe(onSuccess: { _ in
//                                        callbackQueueLabel = DispatchQueue.currentLabel
//                                        completion()
//                                    }).disposed(by: disposeBag)
//                            })
//
//                            expect(callbackQueueLabel) == callbackQueue.label
//                        }
//                    }
//                }
//
//                describe("a provider without a predefined queue") {
//                    var provider: MoyaProvider<GitHub>!
//                    var disposeBag: DisposeBag!
//
//                    beforeEach {
//                        disposeBag = DisposeBag()
//                        provider = MoyaProvider<GitHub>()
//                    }
//
//                    context("the queue is provided with the request") {
//                        it("invokes the callback on the specified queue") {
//                            let requestQueue = DispatchQueue(label: UUID().uuidString)
//                            var callbackQueueLabel: String?
//
//                            waitUntil(action: { completion in
//
//                                provider.rx.request(.zen, callbackQueue: requestQueue)
//                                    .subscribe(onSuccess: { _ in
//                                        callbackQueueLabel = DispatchQueue.currentLabel
//                                        completion()
//                                    }).disposed(by: disposeBag)
//                            })
//
//                            expect(callbackQueueLabel) == requestQueue.label
//                        }
//                    }
//
//                    context("the queue is not provided with the request") {
//                        it("invokes the callback on the main queue") {
//                            var callbackQueueLabel: String?
//
//                            waitUntil(action: { completion in
//                                provider.rx.request(.zen)
//                                    .subscribe(onSuccess: { _ in
//                                        callbackQueueLabel = DispatchQueue.currentLabel
//                                        completion()
//                                    }).disposed(by: disposeBag)
//                            })
//
//                            expect(callbackQueueLabel) == DispatchQueue.main.label
//                        }
//                    }
//                }
//            }
//        }
    }
}
#endif
