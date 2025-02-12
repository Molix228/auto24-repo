import Vapor
import JWT

struct SessionAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // 🔹 Проверяем сессию
        if let userID = request.session.data["userID"], let uuid = UUID(userID) {
            if let user = try await User.find(uuid, on: request.db) {
                request.auth.login(user) // ✅ Авторизуем пользователя по сессии
                return try await next.respond(to: request)
            }
        }

        // 🔹 Если сессии нет – пробуем аутентифицировать по `JWT`
        if let token = request.headers.bearerAuthorization?.token {
            do {
                let payload = try request.jwt.verify(token, as: Payload.self)
                if let user = try await User.find(payload.userID, on: request.db) {
                    request.auth.login(user) // ✅ Авторизуем пользователя по `JWT`
                    return try await next.respond(to: request)
                }
            } catch {
                throw Abort(.unauthorized, reason: "Invalid or expired token")
            }
        }

        // ❌ Если ни один метод не сработал – отклоняем запрос
        throw Abort(.unauthorized, reason: "Access Denied")
    }
}
