ACID Property Isolation

> ACID はデータベースのトランザクションが満たすべき 4 つの基本的な特性を表す頭文字で、それぞれ Atomicity（原子性）、Consistency（一貫性）、Isolation（分離性）、Durability（耐久性）を指します。この中で、Isolation（分離性）はトランザクションが他のトランザクションから独立して実行されることを保証する特性を指します。
>
> 分離性 (Isolation) の主な目的は、複数のトランザクションが同時に実行される場合に、それらが互いに干渉しないようにすることです。これにより、各トランザクションは他のトランザクションが存在しないかのように動作し、データベースの一貫性が保たれます。

- Transaction が互いに影響し合う現象を、**Read Phenomena**という。以下の種類がある。

1.  **Dirty Reads**
    あるトランザクションが別のトランザクションによって変更されたがまだコミットされていないデータを読むこと。更新中の誤ったデータを取得する可能性がある。

2.  **Non-Repeatable Reads**
    あるトランザクションが同じデータを 2 回読む間に別のトランザクションによってそのデータが変更されること。

3.  **Phantom Reads**
    あるトランザクションが行の範囲を 2 回読む間に別のトランザクションによってその範囲に新しい行が追加または削除されること。

# ReadPhenomena の具体例

1. **Dirty Reads**
   トランザクション 1 がアカウント A から 100 ドルをアカウント B に送金しようとし、アカウント A の残高を減らします。
   この時点でトランザクション 2 がアカウント A の残高を読み取りますが、トランザクション 1 はまだコミットされていません。
   トランザクション 1 が何らかの理由でロールバックされると、トランザクション 2 は無効なデータを読み取ったことになります。

2. **Non-Repeatable Reads**
   トランザクション 1 がアカウント A の残高を読み取り、その後にトランザクション 2 がアカウント A の残高を変更し、コミットします。
   トランザクション 1 が再度アカウント A の残高を読み取ると、最初に読み取った値とは異なる値が得られます。

3. **Phantom Reads**
   トランザクション 1 が残高が 1000 ドル以上の全てのアカウントを検索します。
   トランザクション 2 が新しいアカウントを作成し、その残高を 1000 ドルに設定し、コミットします。
   トランザクション 1 が再度同じ検索を実行すると、最初の検索時には存在しなかった新しいアカウントが結果に含まれます。

# ReadPhenomena の対処法

**ANSI**によって定められている 4 つの分離レベルで解決する。

1. **Read Uncommitted**
   この分離レベルは最も低く、他のトランザクションによって変更されたがまだコミットされていないデータの読み取りを許可します。
   Dirty Reads、Non-Repeatable Reads、および Phantom Reads の異常が発生する可能性があります。

2. **Read Committed**
   この分離レベルは、他のトランザクションがコミットするまでデータの読み取りをブロックします。
   Dirty Reads は防止されますが、Non-Repeatable Reads と Phantom Reads の異常が発生する可能性があります。
   ブロックするが、データの取得は可能。ただし、更新前のものが取得される。そのため、更新後に同じクエリを実行すると違う結果になる。3 を引き起こす。

3. **Repeatable Read**
   この分離レベルは、トランザクションの実行中に他のトランザクションによってデータが変更されることを防ぎます。
   Dirty Reads と Non-Repeatable Reads は防止されますが、Phantom Reads の異常が発生する可能性があります。
   他のところで commit されて、データが置き換えられていても、前のクエリと同じデータを返す。

   しかし、update を行うと、他のところの結果を元に行われる。つまり、SELECT で 80 を取得した。その後、他のところで 70 に書き換えられた。もう一度 SELECT すると、80 が返される。そこで、UPDATE を行うと 70 にはならず、60 になる。
   つまり、UPDATE は commit 先の値で行う。これは理想ではない。なぜなら、一貫性がないから。
   postgreSQL の場合は、エラーになる。

4. **Serializable**
   この分離レベルは最も厳格であり、全てのトランザクションをシリアルに実行するかのようにデータベースをロックします。
   Dirty Reads、Non-Repeatable Reads、および Phantom Reads の全ての異常を防止します。
   特定の行に SELECT が発生した時点で、UPDATE できなくなる。これが上記の 3 の問題を防ぐ。ロックされ、Transaction が終わるかタイムアウトまで続く。

以下の表は、ANSI で定義されている 4 つの分離レベルと、それぞれのレベルで発生する可能性がある読み取り現象（Read Phenomena）を示しています。

|                     | Read Uncommitted | Read Committed | Repeatable Read | Serializable |
| ------------------- | ---------------- | -------------- | --------------- | ------------ |
| Dirty Read          | ○                | ×              | ×               | ×            |
| Non-Repeatable Read | ○                | ○              | ×               | ×            |
| Phantom Read        | ○                | ○              | ○               | ×            |

**PostgreSQL の場合は、Read Committed が最低レベル**
