# terraform-azure-vm

for zones:
simply set zone = [1] in resource block 
```
zone = [1]
```
### OR
set it as local and specifr for_each for each vm resource block 
ex: 
```
locals {
  zones = toset(["1","2","3"])
}
```
under vm resource block 
```
for_each = local.zones
zone = each.value
```

#tags
set global tags and add addtional tags for each resource if required. 

```
locals {
  tags = {
    environment = "prod"
    owner = "kk"
    source = "terraform"
  }
}
```
and under resource block add tags as below 

tags = merge(local.tags, {
    workload = "apps"
  })
}
