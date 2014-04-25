rv2da
=====

an application and ruby scripts which compose and decompose rvdata2 (except Scripts) of rpgvxace.
if you need to handle Scripts.rvdata2, use rv2sa (https://github.com/ctmk/rv2sa).

rvdata2をjsonファイルに変換するツールです。
Scripts.rvdata2を変換したい場合は rv2sa (https://github.com/ctmk/rv2sa) を使用できます。

## 使用方法

`rv2da.exe --help` でオプションの詳細を確認できます。

### rvdata2 -> json の変換

`rv2da.exe -d Path/To/Data/Dir -o Path/To/Output/Dir -e exclude`

`Path/To/Data/Dir`: .rvdata2ファイルの置かれたフォルダ(Data/など)へのパス、または.rvdata2ファイルへのパスを指定します。
ディレクトリを指定した場合は、そのディレクトリにある全ての.rvdata2ファイルが処理の対象になります(excludeで指定されたものは除く)。

`Path/To/Output/Dir`: 変換した.jsonファイルを出力するディレクトリを指定します。

`exclude`: 処理をしない条件を書いたファイルを指定します。（デフォルトではScriptsのみが指定されています。）
ファイルに記載する条件には、正規表現を利用できます。

### json -> rvdata2 の変換

`rv2da.exe -c Path/To/Json/Dir -p Path/To/Output/Dir -e exclude`

`Path/To/Json/Dir`: .jsonファイルの置かれたフォルダへのパス、または.jsonファイルへのパスを指定します。
ディレクトリを指定した場合は、そのディレクトリにある全ての.jsonファイルが処理の対象になります(excludeで指定されたものは除く)。

`Path/To/Output/Dir`: 変換した.rvdata2ファイルを出力するディレクトリを指定します。

`exclude`: 処理をしない条件を書いたファイルを指定します。（デフォルトではScriptsのみが指定されています。）
ファイルに記載する条件には、正規表現を利用できます。

## スクリプトの実行方法

rv2da.rb を実行するには、RGSS3で定義されている各クラスの定義が必要になります。
下記の手順でそれらを生成することができます。

### RPGVXAce.chm の準備

RPGツクールVX Ace をインスールした場所にある`RPGVXAce.chm`を、rv2daの`source/`に置いてください。

### .chm ファイルの分解

CLIでrv2daの`source/`に移動し、`hh.exe -decompile decompiled RPGVXAce.chm` を実行してください。
`source/decompiled`に.chmを分解したファイルが生成されます。

### 定義ファイルの生成

`ruby generate_rpg_definitions.rb`を実行してください。`rpg/`ファイルに、RGSS3で定義されているクラス定義を行う.rbファイルが生成されます。

### スクリプトの実行

スクリプトを実行するための準備は以上です。`ruby rv2da.rb`でスクリプトを実行できます。

