# TableViewPlaceholder
UITableView无数据时的提示
![效果图]https://github.com/tengshuq/TableViewPlaceholder/row/masterdemoPicture.gif

简单易用，一行代码回调默认点击事件
```__weak typeof(self)weakSelf = self;
    self.tableView.defaultNoDataViewClickActionBlock = ^(UIView *view) {
        _data = @[@"删除数据，显示默认提示",@"删除数据，显示自定义提示"];
        [weakSelf.tableView reloadData];
    };
```

又或者自定义提示
```
tableView.customNoDataView = [self customNoticeView];
```
