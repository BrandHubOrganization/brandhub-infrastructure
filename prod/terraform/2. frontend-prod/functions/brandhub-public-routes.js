function handler(event) {
    var request = event.request;
    var uri = request.uri;

    if (
        uri === '/privacy' ||
        uri === '/privacy/' ||
        uri === '/terms' ||
        uri === '/terms/'
    ) {
        request.uri = '/index.html';
    }

    return request;
}