@testable import GoogleSignIn

class GIDSignInMock: GIDSignIn {
    
    override var currentUser: GIDGoogleUser? {
        _currentUser
    }
    
    var _currentUser: GIDGoogleUser?
    
    //MARK: - signIn
    
    var signInWithPresentingHintClosureCallsCount: Int = 0
    var signInWithPresentingHintClosureCalled: Bool {
        return signInWithPresentingHintClosureCallsCount > 0
    }
    var signInWithPresentingHintClosureReceivedArguments: (withPresenting: UIViewController, hint: String?, additionalScopes: [String]?, completion: ((GIDSignInResult?, Error?) -> Void)?)?
    var signInWithPresentingHintClosureClosure: ((UIViewController, String?, [String]?, ((GIDSignInResult?, Error?) -> Void)?) -> Void)?
    
    override func signIn(withPresenting presentingViewController: UIViewController,
                         hint: String?,
                         additionalScopes: [String]?, 
                         completion: ((GIDSignInResult?, Error?) -> Void)?) {
        signInWithPresentingHintClosureCallsCount += 1
        signInWithPresentingHintClosureReceivedArguments = (withPresenting: presentingViewController, hint: hint, additionalScopes: additionalScopes, completion: completion)
        signInWithPresentingHintClosureClosure?(presentingViewController, hint, additionalScopes, completion)
    }
    
    // MARK: - signOut
    
    var signOutCallsCount: Int = 0
    var signOutCalled: Bool {
        return signOutCallsCount > 0
    }
    var signOutClosure: (() -> Void)?
    
    override func signOut() {
        signOutCallsCount += 1
        signOutClosure?()
    }
    
    // MARK: - disconnect
    
    var disconnectCompletionCallsCount: Int = 0
    var disconnectCompletionCalled: Bool {
        return disconnectCompletionCallsCount > 0
    }
    var disconnectCompletionClosure: ((((Error?) -> Void)?) -> Void)?
    
    override func disconnect(completion: ((Error?) -> Void)? = nil) {
        disconnectCompletionCallsCount += 1
        disconnectCompletionClosure?(completion)
    }
}
