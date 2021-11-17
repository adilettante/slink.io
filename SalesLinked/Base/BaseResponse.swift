import Foundation

enum BaseResponse {
    /*
     In case there was some problem fetching data from service, this will be returned.
     It really doesn't matter if that is a failure in network layer, parsing error or something else.
     In case data can't be read and parsed properly, something is wrong with server response.
     */
    case serviceOffline

    /* http status code 400 */
    case badRequest

    /* http status code 401 */
    case unauthorized

    /* http status code 404 */
    case notFound

    /* http status code 422 */
    case validationProblem(error: ResponseError)

    /* http status code 500 */
    case unexpectedError(error: ResponseUnexpectedError)
}
