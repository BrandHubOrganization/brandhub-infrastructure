function handler(event) {
    var request = event.request;
    var uri = request.uri;

    if (uri === '/privacy' || uri === '/privacy/') {
        request.uri = '/privacy/index.html';
    } else if (uri === '/terms' || uri === '/terms/') {
        request.uri = '/terms/index.html';
    } else if (uri === '/help/faq' || uri === '/help/faq/') {
        request.uri = '/help/faq/index.html';
    } else if (uri === '/blog' || uri === '/blog/') {
        request.uri = '/blog/index.html';
    } else if (uri.indexOf('/blog/') === 0 && uri.indexOf('.') === -1) {
        var cleanUri = uri.charAt(uri.length - 1) === '/' ? uri.slice(0, -1) : uri;
        request.uri = cleanUri + '/index.html';
    }

    return request;
}
