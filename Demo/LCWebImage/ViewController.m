//
//  ViewController.m
//  LCWebImage
//
//  Created by 刘畅 on 2022/5/21.
//

#import "ViewController.h"
#import "UIImageView+LCWebImage.h"
#import "YYImage/YYAnimatedImageView.h"
#import "YYImage/YYImage.h"
#import "UIButton+LCWebImage.h"
@interface UIImageTableViewCell : UITableViewCell
@property (nonatomic, weak) UIImageView *bgImageView;
@end

@implementation UIImageTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    UIImageView *bgImageView = [[UIImageView alloc] init];
    YYAnimatedImageView *bgImageView = [[YYAnimatedImageView alloc] init];

    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:bgImageView];
    _bgImageView = bgImageView;
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgImageView.frame = CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height-20);
}

@end
@interface ViewController()<UITableViewDataSource>
@property (nonatomic, strong) NSArray *images;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 自定义装换
    [(LCAutoPurgingImageCache *)[LCImageDownloader defaultInstance].imageCache setCustomTransform:^UIImage * _Nonnull(NSData * _Nonnull data, NSString * _Nonnull identifier) {
        return [[YYImage alloc] initWithData:data scale:UIScreen.mainScreen.scale];
    }];

    self.images = @[
        // gif
        @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fp3.itc.cn%2Fq_70%2Fimages02%2F20210528%2Fc08685d26c254a53a8b02ed0017b7cd0.gif&refer=http%3A%2F%2Fp3.itc.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1655369709&t=6d51e3afd59f60c42a5680e2152ff47b",
        @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.mp.itc.cn%2Fq_mini%2Cc_zoom%2Cw_640%2Fupload%2F20170812%2Fe8f26826df854b0baa95fbcaf7ddfeb1.jpg&refer=http%3A%2F%2Fimg.mp.itc.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1655518221&t=6a9fd3f6861986cd8bb2488fc89309e5",
        @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fq_70%2Cc_zoom%2Cw_640%2Fimages%2F20191205%2Fd2dd1a08ce574cd3b1ca109f61f9844d.gif&refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1655518221&t=563b5020a58a4c08395de188af5ec35d",
        @"https://img0.baidu.com/it/u=512340543,3139277133&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=281",
        @"https://img0.baidu.com/it/u=3217543765,3223180824&fm=253&fmt=auto&app=120&f=JPEG?w=1200&h=750",
        @"https://img0.baidu.com/it/u=1149498394,1442276907&fm=253&fmt=auto&app=120&f=JPEG?w=1000&h=500",
        @"https://img2.baidu.com/it/u=2147843660,3054818539&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=313",
        @"https://img1.baidu.com/it/u=131948171,990039642&fm=253&fmt=auto&app=138&f=JPEG?w=667&h=500",
        @"https://img2.baidu.com/it/u=1404596068,2549809832&fm=253&fmt=auto&app=120&f=JPEG?w=1067&h=800",
        @"https://img2.baidu.com/it/u=3209059830,1377316442&fm=253&fmt=auto&app=138&f=JPEG?w=667&h=500",
        @"https://img2.baidu.com/it/u=4185738571,2433540613&fm=253&fmt=auto&app=138&f=JPEG?w=708&h=500",
        @"https://img1.baidu.com/it/u=3425784307,1085094197&fm=253&fmt=auto&app=138&f=JPEG?w=889&h=500",
        // webp
        @"https://isparta.github.io/compare-webp/image/gif_webp/webp/1.webp",
        @"https://isparta.github.io/compare-webp/image/gif_webp/webp/2.webp"
    ];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.dataSource = self;
    tableView.rowHeight = 200;
    [tableView registerClass:UIImageTableViewCell.class forCellReuseIdentifier:@"cell"];
    [self.view addSubview:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell.bgImageView lc_setImageWithURL:[NSURL URLWithString:self.images[indexPath.row]] placeholderImage:nil options:(0)];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.images.count;
}
@end
