import Vapor
import VaporInterface

var users = [UUID: User.Read]()

func routes(_ app: Application) throws {
    app.on(EmptyRequest.self) { _, vaporRequest in
        return .init()
    }

    app.on(GETRequest.self) { getRequest, vaporRequest in
        return .init()
    }

    app.on(GETWithParameterRequest.self) { getWithParameterRequest, vaporRequest in
        return .init(value: getWithParameterRequest.parameters.value)
    }

    app.on(GETWithQueryRequest.self) { getWithQueryRequest, vaporRequest in
        return .init(value: getWithQueryRequest.query.value, optionalValue: getWithQueryRequest.query.optionalValue)
    }

    app.on(POSTWithBodyRequest.self) { postWithBodyRequest, vaporRequest in
        return .init(value: postWithBodyRequest.body.value, optionalValue: postWithBodyRequest.body.optionalValue)
    }

    app.on(IndexUsersRequest.self) { indexUsersRequest, vaporRequest in
        return .init(users: Array(users.values))
    }

    app.on(CreateUserRequest.self) { createUserRequest, vaporRequest in
        let user = User.Read(
            id: UUID(),
            name: createUserRequest.user.name,
            emailAddress: createUserRequest.user.emailAddress,
            lastActiveAt: Date()
        )

        users[user.id] = user

        return .init(user: user)
    }

    app.on(ReadUserRequest.self) { readUserRequest, vaporRequest in
        guard let user = users[readUserRequest.id] else {
            throw Abort(.notFound)
        }

        return .init(user: user)
    }

    app.on(PartialUpdateUserRequest.self) { partialUpdateUserRequest, vaporRequest in
        guard var user = users[partialUpdateUserRequest.user.id] else {
            throw Abort(.notFound)
        }

        user.name = partialUpdateUserRequest.user.name ?? user.name
        user.emailAddress = partialUpdateUserRequest.user.emailAddress ?? user.emailAddress
        user.lastActiveAt = partialUpdateUserRequest.user.lastActiveAt ?? user.lastActiveAt

        users[partialUpdateUserRequest.user.id] = user

        return .init(user: user)
    }

    app.on(FullUpdateUserRequest.self) { fullUpdateUserRequest, vaporRequest in
        guard var user = users[fullUpdateUserRequest.user.id] else {
            throw Abort(.notFound)
        }

        user.name = fullUpdateUserRequest.user.name
        user.emailAddress = fullUpdateUserRequest.user.emailAddress
        user.lastActiveAt = fullUpdateUserRequest.user.lastActiveAt

        users[fullUpdateUserRequest.user.id] = user

        return .init(user: user)
    }

    app.on(DeleteUserRequest.self) { deleteUserRequest, vaporRequest in
        guard let user = users.removeValue(forKey: deleteUserRequest.id) else {
            throw Abort(.notFound)
        }

        return .init(user: user)
    }
}
