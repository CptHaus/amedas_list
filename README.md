# amedas_list
AMeDAS地点リストの処理に関連するツール

## 現在の観測と統計的に接続されている観測期間の初日を取得
### パッケージ
![image](https://github.com/user-attachments/assets/67ea8c82-0ca0-4d4d-97b5-1f8db8f6f1cc)

### ディレクトリ・ファイルの説明
- csv: ツールを実行して出力される観測点リストのcsvファイルが保存される
  - .csvファイルの14列目までは観測地点の名前や位置などの基本情報
  - .csvファイルの15行目が統計接続されている観測期間の開始日
- exec: ツールを実行するためのシェルスクリプトexec.shがある
  - exec.sh の以下の項目を指定して実行すると, csvディレクトリ以下にファイルが出力される
    - encd: 出力されるファイルの文字のエンコーデイングを指定
    - obs_type: 観測項目を指定(Precipitation, WindSPeed, Temperature, Sunshine, Snow, Humidityのいずれか)
    - cmp: fortranのコンパイラを指定
  - exec.shを実行すると, src/connected_list.f90 がコンパイル・実行され, 統計接続された期間のリストとログファイルが出力される
- log: ログファイルの出力先
- meta_data: 気象庁が公開しているAMeDAS地点に関するメタデータファイル(amdmaster.index4.txt)を保存
  - [ダウンロード元のページ](https://www.data.jma.go.jp/stats/data/mdrr/man/kansoku_gaiyou.html)
  - ↑のページの"アメダス地点情報履歴ファイル"からデータを取得
  - 現在, meta_dataの保存しているamdmaster.index4.txtは2025/04/23に取得
  - [ファイルのフォーマットに関する説明](https://www.data.jma.go.jp/stats/data/mdrr/man/amdmasterindex4_format.pdf)
- src: リストの作成を行うfortranコードがある
  - connected_list.f90: obs_typeで指定した観測項目について, 現観測と統計接続された期間の開始日を観測地点ごとに書き出す
 
### 実行手順
1. exec.shの説明に挙げた変数を目的に合わせて編集
2. 実行: `$ bash exec.sh`
3. logディレクトリ内にexec.shを実行した日付を名前に含むログファイルができるので, 中身を確認
4. csvディレクトリ内に出力されたcsvファイルの中身を確認
