function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // 301 redirect trailing slashes (except root '/') to canonical clean URLs
    if (uri.length > 1 && uri.charAt(uri.length - 1) === '/') {
        var stripped = uri.replace(/\/+$/, '');
        var qs = Object.keys(request.querystring || {})
            .map(function (k) {
                var entry = request.querystring[k];
                return entry && entry.value
                    ? encodeURIComponent(k) + '=' + encodeURIComponent(entry.value)
                    : encodeURIComponent(k);
            })
            .join('&');
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                location: { value: stripped + (qs ? '?' + qs : '') }
            }
        };
    }

    if (uri === '/privacy') {
        request.uri = '/privacy/index.html';
    } else if (uri === '/terms') {
        request.uri = '/terms/index.html';
    } else if (uri === '/help/faq') {
        request.uri = '/help/faq/index.html';
    } else if (uri === '/blog') {
        request.uri = '/blog/index.html';
    } else if (uri.indexOf('/blog/') === 0 && uri.indexOf('.') === -1) {
        request.uri = uri + '/index.html';
    }

    return request;
}
