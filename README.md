ネタプログラム言語クリエイター - Youma
===============

Introduction
---------------
「BF風言語解析器 - Windstorm」を利用し、
ネタ言語の生成や実行をおこなうスクリプトです。

Rubyのrakeを利用して実装しているため、Ruby環境が必要です。
また、内部で使用するWindstormの制限を受けます。
詳しくはWindstormのREADMEをご覧ください。

https://github.com/parrot-studio/windstorm

Installation
---------------
    gem install bundler # if not installed
    git clone git://github.com/parrot-studio/youma.git
    cd youma
    bundle # install 'rake' and 'windstorm'

Usage
---------------
### 概要
Youmaで実行スクリプトを生成するには、
命令と文字列の対応を定めた定義ファイルが必要です。
定義ファイルに従ってWindstormがソースコードを解釈し実行します。

YoumaはWindstormとのやりとりを円滑にするため、
様々なコマンド＝Rakeタスクを定義しています。

### 定義ファイルとソースコードの準備

Windstormの仕様に依存しますので、
WindstormのREADMEを参照してください。

https://github.com/parrot-studio/windstorm

### 実行方法

    cd youma
    rake task-name [args] [-- opts]

### rakeタスク

- help   : 各タスクの概要
- test   : 開発用のタスク
- create : 実行スクリプトの生成
- sample : サンプルの表示と実行

#### オプションの渡し方

基本引数の後に、「 -- 」を入れて、
その後に各オプションを入れていきます。
例えば以下のような形です。

    # ファイルを指定するタスクに対するオプション
    rake test:build test.yml hello.test -- -d -s 10
    
    # 単体で実行されるタスクに対するオプション
    rake sample:bf -- -d

#### help

- rake help

各タスクに対する概要を表示します。

#### test

- rake test:help

各test系タスクの概要と、オプションの説明を表示します。

- rake test:filter _table-file_ _source-file_

定義ファイルを元に、ソースファイルに含まれる命令語を抽出します。
内部的にはWindstorm::Executor#filterを呼んでいます。

- rake test:build _table-file_ _source-file_

filterを実行した後、実行器が解釈できる命令に置き換えます。
内部的にはWindstorm::Executor#buildを呼んでいます。

- rake test:debug _table-file_ _source-file_ [-- opts]

定義とソースを元に、デバッグモードで実行します。
内部的にはWindstorm::Executor#debugを呼んでいます。

- rake test:execute _table-file_ _source-file_ [-- opts]

定義とソースを元に、通常モードで実行します。
内部的にはWindstorm::Executor#executeを呼んでいます。

- テストオプションについて

test:debugとtest:executeにはオプションが渡せます。

- -d : デバッグモードで起動（test:debugはデフォルトで有効）
- -l : looseモードで起動

オプションの詳細については、WindstormのREADMEを参照してください。

https://github.com/parrot-studio/windstorm

#### create

- rake create:help

各create系タスクの概要と、オプションの説明を表示します。

- rake create:source _name_ _table-file_ [-- opts]

Rubyに引き渡して実行するタイプのソースコードを生成します。
定義をソースに埋め込むため、単体で実行可能です。

デフォルトの生成先は「youma/bin/_name_.rb」です
実行する時は以下のようにします。

    ruby bin/name.rb source-file [opts]

実行時オプションについては、後述のスクリプト仕様で確認してください。

- rake create:exec _name_ _table-file_ [-- opts]

create:sourceを実行した後、以下の作業をおこないます。

- _name.rb_ を _name_ に変更
- 1行目にshebangを埋め込む
 - デフォルトは「実行時に使われたrakeが存在するディレクトリのrubyというファイル」
 - 「rakeを実行したrubyのpath」の取得方法がわからないため
- chmod +x _name_

つまり、単体で実行可能なスクリプトを生成します。
（仕組み上、Windows環境では動作しません）

実行時には以下のようにします。

    bun/name source-file [opts]

実行時オプションについては、後述のスクリプト仕様で確認してください。

- 生成オプションについて

create:sourceとcreate:execには以下のオプションが渡せます。

- -d / --debug

生成スクリプトのデフォルトオプションに「-d」を追加する

- -l / --loose

生成スクリプトのデフォルトオプションに「-l」を追加する

- -o _path_ / --output-path _path_

生成スクリプトを出力するディレクトリを指定。
（指定したディレクトリが事前に存在しない場合はエラー）

- -r _path_ / --ruby-path _path_

shebangに埋め込むrubyプログラムのpathを指定。
create:execでのみ有効。
（指定したプログラムが存在しない場合はエラー）


#### sample

    rake sample:help

各サンプルの簡単なコンセプト説明と、
元ネタがある場合や原作者の方がいる場合、そのクレジットを表示します。

    rake sample:name [-- -d]

_name_に対応するサンプルの定義とソースコード、実行結果を表示します。
「-d」オプションが渡された場合、デバッグモードで実行します。
ソース一式はsample/_name_以下にあります。

### 実行スクリプト仕様

create:sourceで出力した場合はruby経由で実行します。

    ruby created-file source-file [opts]
    ruby created-file -h # help
    ruby created-file -e code [opts] # one-liner

create:execで出力した場合は単体で実行できます。
（Windowsは非対応）

    created-file source-file [opts]
    created-file -h # help
    created-file -e code [opts] # one-liner

オプションとして以下が指定可能です。
（rakeタスクと異なり、optsの前に「 -- 」は不要です）

- -h / --help

ソースを実行せず、オプションの説明を表示します。

- -e _code_ / --eval _code_

与えられた文字列をファイル名ではなく、ソースそのものとして実行します。

- -i / --ignore

生成時にデフォルトオプションとして指定したオプションを無視し、
改めてオプションを指定します。

例えば、-lがデフォルトで埋め込まれたスクリプトを実行する際、
-iを与えることで、strictモードで起動することが可能です。

- -d / --debug

デバッグモードで実行します。
詳細はWindstormのREADMEを参照してください。

- -l / --loose

looseモードで実行します。
詳細はWindstormのREADMEを参照してください。

- -f / --flash

flashモードで実行します。
詳細はWindstormのREADMEを参照してください。

- -s _val_ / --size _val_

実行器のバッファサイズを指定します。
詳細はWindstormのREADMEを参照してください。

Note
---------------
- Youmaとは、某秘境のアイドル「二代目ぐんまちゃん」の「本名」です

License
---------------
The MIT License

see LICENSE file for detail

Author
---------------
ぱろっと(@parrot_studio / parrot.studio.dev at gmail.com)
