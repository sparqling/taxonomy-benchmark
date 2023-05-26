# Taxonomy benchmark

## Original data
[NCBI Taxonomy database](https://www.ncbi.nlm.nih.gov/taxonomy)

```
$ wget ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump_archive/taxdmp_2019-05-01.zip
URL transformed to HTTPS due to an HSTS policy
...
HTTP による接続要求を送信しました、応答を待っています... 200 OK
...
```

```
$ wget ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdmp.zip
$ wget ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdmp.zip.md5
$ md5sum -c taxdmp.zip.md5
taxdmp.zip: OK
$ unzip taxdump.zip -d taxdump
$ ./bin/make_ttl.pl taxdump/nodes.dmp taxdump/names.dmp > taxonomy.ttl
```
