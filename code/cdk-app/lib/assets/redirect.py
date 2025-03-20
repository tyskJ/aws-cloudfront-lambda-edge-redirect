def lambda_handler(event, context):
    request = event['Records'][0]['cf']['request']
    request_path = request['uri']

    # Pathチェック
    if request_path == '/test1/':
        redirect_url = 'https://www.sub.mtdevelop.click/test1/'
    elif request_path == '/test2/':
        redirect_url = 'https://www.sub.mtdevelop.click/test2/'
    else:
        # マッチしない場合は元のリクエストを返す
        return request

    # リダイレクトレスポンス
    response = {
        'status': '301',
        'statusDescription': 'MovedPermanently',
        'headers': {
            'location': [{
                'key': 'Location',
                'value': redirect_url
            }]
        }
    }

    return response
