# これは何?

IIJmio SIM のデータ通信量を mackerel でメトリクスを取るツールです

# つかいかた

環境変数に以下を設定

```
IIJ_ID
IIJ_PASS
MACKEREL_API_KEY
MACKEREL_POST_URI
WEBHOOK_URL
```

- `WEBHOOK_URL` は任意

```
bundle exec main.rb
```

# Herokuで動作させる

```
heroku create
git push heroku master
```

## 環境変数を設定

```
heroku config:set IIJ_ID=********
heroku config:set IIJ_PASS=********
heroku config:set MACKEREL_API_KEY=********
heroku config:set MACKEREL_POST_URI=********
heroku config:set WEBHOOK_URL=********
```

## 動作確認

```
heroku run "ruby main.rb"
```

## 毎日0時に実行したい

see: http://qiita.com/kasei-san/items/909f17c2c42b7e3a8489#heroku-scheduler%E3%81%AE%E8%A8%AD%E5%AE%9A

