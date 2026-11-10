function handler(event) {
    var request = event.request;
    var uri = request.uri;

    if (uri === '/privacy' || uri === '/privacy/') {
        request.uri = '/privacy/index.html';
    } else if (uri === '/terms' || uri === '/terms/') {
        request.uri = '/terms/index.html';
    } else if (uri === '/help/faq' || uri === '/help/faq/') {
        request.uri = '/help/faq/index.html';
    }

    return request;
}
