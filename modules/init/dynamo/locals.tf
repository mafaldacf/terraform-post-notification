locals {
  tables = {
    "blobs" = {
      partition_key = "k"
    },
    "keyvalue" = {
      partition_key = "k"
    },
    "cscopes" = {
      partition_key = "cid"
    },
    "rendezvous" = {
      partition_key = "rid"
    }
  }
}