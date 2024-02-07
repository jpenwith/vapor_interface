Tool to define all information for a Vapor route in a single place

e.g. you have a route to update a user's profile: PUT /user/:id/profile/update

This takes the user's id as a parameter, and the rest of the information in the request body. It returns a User object

Define it like this: 

```swift
struct User: Codable {
    let id: UUID
    let firstName: String?
    let lastName: String?
    let dateOfBirth: Date?
}

struct UpdateUserProfileRequest: VaporInterface.Request {
    let user: User
    
    struct Route: VaporInterface.Route {
        static let path = "user/:id/profile/update"

        static let method: HTTPMethod = .PATCH

        struct Parameters: Content {
            let id: UUID
        }
    }

    struct Body: Content {
        public let firstName: String?
        public let lastName: String?
        public let dateOfBirth: Date?
    }

    struct Response: VaporInterface.Response {
        let user: User

        public struct Body: Content {
            let user: User
        }
        
        public init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: Body) throws {
            self.user = body.user
        }

        public var body: Body { .init(user: user) }
    }
    
    public init(parameters: Route.Parameters, query: EmptyRequestQuery, headers: HTTPHeaders, body: Body) throws {
        self.user = .init(
            id: parameters.id,
            firstName: body.firstName,
            lastName: body.lastName,
            dateOfBirth: body.dateOfBirth
        )
    }

    public var parameters: Route.Parameters {
        .init(id: user.id)
    }

    public var body: Body {
        .init(firstName: user.firstName, lastName: user.lastName, dateOfBirth: user.dateOfBirth)
    }
}
```


Receive this request in Vapor with:

```swift
app.on(UpdateUserProfileRequest.self) { updateUserProfileRequest, vaporRequest in
  //Access the decoded user
  let updateUser = updateUserProfileRequest.user

  //Update the database, etc
  //...
  let updatedUser = ...

  //Return the response
  return .init(user: updatedUser)
}
```


Send this request (e.g. from an iOS app) with
```swift
let client = Client(url: URL(string: "https://your.api.com/version/path")!, networkAdapter: URLSessionClientNetworkAdapter(.shared))
let updateUser = User(id: ..., firstName: "John")
let updateUserProfileRequest = UpdateUserProfileRequest(user: user)
let updateUserProfileResponse = client.execute(updateUserProfileRequest)
print(updateUserProfileResponse.user)
```
