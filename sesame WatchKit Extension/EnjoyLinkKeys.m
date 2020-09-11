//
//  EnjoyLinkKeys.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/11.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import "EnjoyLinkKeys.h"

@interface EnjoyLinkKeys ()

@property (strong, nonatomic) NSMutableDictionary* keys;

@end

@implementation EnjoyLinkKeys

+ (EnjoyLinkKeys *)sharedKeys {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (BleKey *)findKey: (NSString *) macAddress {
    return [self.keys valueForKey:macAddress];
}

- (id)init {
    if((self = [super init])) {
        self.keys = [NSMutableDictionary dictionaryWithCapacity:100];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:50];
        [array addObject:@"{\"encrypt\":true,\"code\":10000,\"desc\":\"请求执行成功！\",\"rts\":\"0000000000\",\"result\":{\"keys\":[{\"blueToothDeviceVo\":{\"deviceId\":8154,\"version\":\"32\",\"secretKey\":\"zgFONbCaGgBsBywnZcHTkA\",\"macAddress\":\"40:BD:32:B0:1B:F1\",\"guardId\":6767,\"guardName\":\"1栋大堂\",\"code\":\"20181017155641\",\"supplierType\":\"1\",\"orderNum\":0},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8156,\"version\":\"32\",\"secretKey\":\"nxzKBFmHUq+FJ9qm3kBE+A\",\"macAddress\":\"40:BD:32:AF:A5:FD\",\"guardId\":6765,\"guardName\":\"北门\",\"code\":\"20181017164904\",\"supplierType\":\"1\",\"orderNum\":2},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8157,\"version\":\"32\",\"secretKey\":\"Il3ITyDWG4gL4axaXtN9VA\",\"macAddress\":\"50:F1:4A:F8:79:3A\",\"guardId\":6764,\"guardName\":\"西门\",\"code\":\"20181017172830\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15772,\"version\":\"32\",\"secretKey\":\"g1c41c4IwXl3IvEpD2RORQ\",\"macAddress\":\"B0:7E:11:E9:EC:D0\",\"guardId\":12135,\"guardName\":\"1栋负一后门\",\"code\":\"20190523162150\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8158,\"version\":\"32\",\"secretKey\":\"N86d6EQUg2ZYCSx2YnISDw\",\"macAddress\":\"40:BD:32:AF:AC:1D\",\"guardId\":6763,\"guardName\":\"东门单车行道\",\"code\":\"20181017180546\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15771,\"version\":\"32\",\"secretKey\":\"MD7yccoRPYAk5OeGuvMRUg\",\"macAddress\":\"B0:7E:11:F4:C4:D4\",\"guardId\":12134,\"guardName\":\"1栋负一正门\",\"code\":\"20190523154340\",\"supplierType\":\"1\",\"orderNum\":5},\"keyType\":\"01\"}],\"url\":\"semtec-ss1\"}}"];
        [array addObject:@"{\"encrypt\":true,\"code\":10000,\"desc\":\"请求执行成功！\",\"rts\":\"0000000000\",\"result\":{\"keys\":[{\"blueToothDeviceVo\":{\"deviceId\":10855,\"version\":\"32\",\"secretKey\":\"YyMs5BXAg5E+C8mK9MW7Cg\",\"macAddress\":\"30:45:11:6E:23:B5\",\"guardId\":8465,\"guardName\":\"3栋大堂\",\"code\":\"20181128104205\",\"supplierType\":\"1\",\"orderNum\":0},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15773,\"version\":\"32\",\"secretKey\":\"Ml1p+jJ9m0q9oQY8UAixMQ\",\"macAddress\":\"B0:7E:11:F4:FC:AD\",\"guardId\":12136,\"guardName\":\"3栋负一正门\",\"code\":\"20190523164943\",\"supplierType\":\"1\",\"orderNum\":1},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8156,\"version\":\"32\",\"secretKey\":\"nxzKBFmHUq+FJ9qm3kBE+A\",\"macAddress\":\"40:BD:32:AF:A5:FD\",\"guardId\":6765,\"guardName\":\"北门\",\"code\":\"20181017164904\",\"supplierType\":\"1\",\"orderNum\":2},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15774,\"version\":\"32\",\"secretKey\":\"EmXrF0mIQtZIih/CnrNBnw\",\"macAddress\":\"B0:7E:11:F4:C4:C5\",\"guardId\":12137,\"guardName\":\"3栋负二正门\",\"code\":\"20190523172517\",\"supplierType\":\"1\",\"orderNum\":2},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8157,\"version\":\"32\",\"secretKey\":\"Il3ITyDWG4gL4axaXtN9VA\",\"macAddress\":\"50:F1:4A:F8:79:3A\",\"guardId\":6764,\"guardName\":\"西门\",\"code\":\"20181017172830\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8158,\"version\":\"32\",\"secretKey\":\"N86d6EQUg2ZYCSx2YnISDw\",\"macAddress\":\"40:BD:32:AF:AC:1D\",\"guardId\":6763,\"guardName\":\"东门单车行道\",\"code\":\"20181017180546\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"}],\"url\":\"semtec-ss1\"}}"];
        [array addObject:@"{\"encrypt\":true,\"code\":10000,\"desc\":\"请求执行成功！\",\"rts\":\"0000000000\",\"result\":{\"keys\":[{\"blueToothDeviceVo\":{\"deviceId\":15775,\"version\":\"32\",\"secretKey\":\"kP+uYSA7VnfIcElRl0p3rA\",\"macAddress\":\"B0:7E:11:F4:D5:A8\",\"guardId\":12138,\"guardName\":\"4栋负一正门\",\"code\":\"20190524100429\",\"supplierType\":\"1\",\"orderNum\":0},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15776,\"version\":\"32\",\"secretKey\":\"DO+4eGfViWNRUp4h57k7yw\",\"macAddress\":\"B0:7E:11:ED:E3:CB\",\"guardId\":12139,\"guardName\":\"4栋负二正门\",\"code\":\"20190524102316\",\"supplierType\":\"1\",\"orderNum\":1},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8156,\"version\":\"32\",\"secretKey\":\"nxzKBFmHUq+FJ9qm3kBE+A\",\"macAddress\":\"40:BD:32:AF:A5:FD\",\"guardId\":6765,\"guardName\":\"北门\",\"code\":\"20181017164904\",\"supplierType\":\"1\",\"orderNum\":2},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8157,\"version\":\"32\",\"secretKey\":\"Il3ITyDWG4gL4axaXtN9VA\",\"macAddress\":\"50:F1:4A:F8:79:3A\",\"guardId\":6764,\"guardName\":\"西门\",\"code\":\"20181017172830\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8158,\"version\":\"32\",\"secretKey\":\"N86d6EQUg2ZYCSx2YnISDw\",\"macAddress\":\"40:BD:32:AF:AC:1D\",\"guardId\":6763,\"guardName\":\"东门单车行道\",\"code\":\"20181017180546\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":10856,\"version\":\"32\",\"secretKey\":\"VpAPKk9IW8ABkiI7bWvNGQ\",\"macAddress\":\"30:45:11:6B:A3:C4\",\"guardId\":8466,\"guardName\":\"4栋大堂\",\"code\":\"20181128102230\",\"supplierType\":\"1\",\"orderNum\":5},\"keyType\":\"01\"}],\"url\":\"semtec-ss1\"}}"];
        [array addObject:@"{\"encrypt\":true,\"code\":10000,\"desc\":\"请求执行成功！\",\"rts\":\"0000000000\",\"result\":{\"keys\":[{\"blueToothDeviceVo\":{\"deviceId\":10857,\"version\":\"32\",\"secretKey\":\"4JZAj8LMzp7ENRoHc3QDgw\",\"macAddress\":\"40:BD:32:AF:98:AB\",\"guardId\":8467,\"guardName\":\"5栋大堂\",\"code\":\"20181128100327\",\"supplierType\":\"1\",\"orderNum\":0},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8156,\"version\":\"32\",\"secretKey\":\"nxzKBFmHUq+FJ9qm3kBE+A\",\"macAddress\":\"40:BD:32:AF:A5:FD\",\"guardId\":6765,\"guardName\":\"北门\",\"code\":\"20181017164904\",\"supplierType\":\"1\",\"orderNum\":2},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8157,\"version\":\"32\",\"secretKey\":\"Il3ITyDWG4gL4axaXtN9VA\",\"macAddress\":\"50:F1:4A:F8:79:3A\",\"guardId\":6764,\"guardName\":\"西门\",\"code\":\"20181017172830\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15778,\"version\":\"32\",\"secretKey\":\"cwAanUpYy4fqRhrQcRIseA\",\"macAddress\":\"B0:7E:11:E9:EC:9F\",\"guardId\":12141,\"guardName\":\"5栋负一正门\",\"code\":\"20190524152745\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15777,\"version\":\"32\",\"secretKey\":\"NgiANpA/4yB/toFFKem72w\",\"macAddress\":\"B0:7E:11:F4:F3:A3\",\"guardId\":12140,\"guardName\":\"5栋负二正门\",\"code\":\"20190524105501\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8158,\"version\":\"32\",\"secretKey\":\"N86d6EQUg2ZYCSx2YnISDw\",\"macAddress\":\"40:BD:32:AF:AC:1D\",\"guardId\":6763,\"guardName\":\"东门单车行道\",\"code\":\"20181017180546\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"}],\"url\":\"semtec-ss1\"}}"];
        [array addObject:@"{\"encrypt\":true,\"code\":10000,\"desc\":\"请求执行成功！\",\"rts\":\"0000000000\",\"result\":{\"keys\":[{\"blueToothDeviceVo\":{\"deviceId\":10858,\"version\":\"32\",\"secretKey\":\"HrY29TjQeKttsZllqUxSAQ\",\"macAddress\":\"40:BD:32:AF:98:F4\",\"guardId\":8468,\"guardName\":\"6栋大堂\",\"code\":\"20181127171205\",\"supplierType\":\"1\",\"orderNum\":0},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8156,\"version\":\"32\",\"secretKey\":\"nxzKBFmHUq+FJ9qm3kBE+A\",\"macAddress\":\"40:BD:32:AF:A5:FD\",\"guardId\":6765,\"guardName\":\"北门\",\"code\":\"20181017164904\",\"supplierType\":\"1\",\"orderNum\":2},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8157,\"version\":\"32\",\"secretKey\":\"Il3ITyDWG4gL4axaXtN9VA\",\"macAddress\":\"50:F1:4A:F8:79:3A\",\"guardId\":6764,\"guardName\":\"西门\",\"code\":\"20181017172830\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15779,\"version\":\"32\",\"secretKey\":\"VZ1rvtNrw8MwZY/VQkC8QA\",\"macAddress\":\"B0:7E:11:E9:1C:51\",\"guardId\":12142,\"guardName\":\"6栋负一正门\",\"code\":\"20190524154605\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8158,\"version\":\"32\",\"secretKey\":\"N86d6EQUg2ZYCSx2YnISDw\",\"macAddress\":\"40:BD:32:AF:AC:1D\",\"guardId\":6763,\"guardName\":\"东门单车行道\",\"code\":\"20181017180546\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15780,\"version\":\"32\",\"secretKey\":\"d66cQ1SrJsh1ai54dxCrKA\",\"macAddress\":\"B0:7E:11:F4:DD:AA\",\"guardId\":12143,\"guardName\":\"6栋负二正门\",\"code\":\"20190524160741\",\"supplierType\":\"1\",\"orderNum\":5},\"keyType\":\"01\"}],\"url\":\"semtec-ss1\"}}"];
        [array addObject:@"{\"encrypt\":true,\"code\":10000,\"desc\":\"请求执行成功！\",\"rts\":\"0000000000\",\"result\":{\"keys\":[{\"blueToothDeviceVo\":{\"deviceId\":8159,\"version\":\"32\",\"secretKey\":\"eu+lR5MmmlkDcdamxgjlhQ\",\"macAddress\":\"40:BD:32:B0:18:0A\",\"guardId\":6762,\"guardName\":\"7栋大堂\",\"code\":\"20181017190350\",\"supplierType\":\"1\",\"orderNum\":2},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8156,\"version\":\"32\",\"secretKey\":\"nxzKBFmHUq+FJ9qm3kBE+A\",\"macAddress\":\"40:BD:32:AF:A5:FD\",\"guardId\":6765,\"guardName\":\"北门\",\"code\":\"20181017164904\",\"supplierType\":\"1\",\"orderNum\":2},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8157,\"version\":\"32\",\"secretKey\":\"Il3ITyDWG4gL4axaXtN9VA\",\"macAddress\":\"50:F1:4A:F8:79:3A\",\"guardId\":6764,\"guardName\":\"西门\",\"code\":\"20181017172830\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15782,\"version\":\"32\",\"secretKey\":\"h3AS3ODoWnKR88wI//uDSQ\",\"macAddress\":\"B0:7E:11:E9:E2:18\",\"guardId\":12145,\"guardName\":\"7栋负一正门\",\"code\":\"20190524163453\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8158,\"version\":\"32\",\"secretKey\":\"N86d6EQUg2ZYCSx2YnISDw\",\"macAddress\":\"40:BD:32:AF:AC:1D\",\"guardId\":6763,\"guardName\":\"东门单车行道\",\"code\":\"20181017180546\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15781,\"version\":\"32\",\"secretKey\":\"/VvGDkpxe0sibnATNjS6DA\",\"macAddress\":\"B0:7E:11:ED:EB:9A\",\"guardId\":12144,\"guardName\":\"7栋负二正门\",\"code\":\"20190524162747\",\"supplierType\":\"1\",\"orderNum\":5},\"keyType\":\"01\"}],\"url\":\"semtec-ss1\"}}"];
        [array addObject:@"{\"encrypt\":true,\"code\":10000,\"desc\":\"请求执行成功！\",\"rts\":\"0000000000\",\"result\":{\"keys\":[{\"blueToothDeviceVo\":{\"deviceId\":10859,\"version\":\"32\",\"secretKey\":\"85u8zzZTv/Nt/lZE6KJ1ng\",\"macAddress\":\"40:BD:32:AF:A9:2B\",\"guardId\":8470,\"guardName\":\"8栋大堂\",\"code\":\"20181127164530\",\"supplierType\":\"1\",\"orderNum\":0},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8156,\"version\":\"32\",\"secretKey\":\"nxzKBFmHUq+FJ9qm3kBE+A\",\"macAddress\":\"40:BD:32:AF:A5:FD\",\"guardId\":6765,\"guardName\":\"北门\",\"code\":\"20181017164904\",\"supplierType\":\"1\",\"orderNum\":2},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8157,\"version\":\"32\",\"secretKey\":\"Il3ITyDWG4gL4axaXtN9VA\",\"macAddress\":\"50:F1:4A:F8:79:3A\",\"guardId\":6764,\"guardName\":\"西门\",\"code\":\"20181017172830\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15784,\"version\":\"32\",\"secretKey\":\"jvobm0X0IC0u4l77WU6xEw\",\"macAddress\":\"B0:7E:11:F4:F3:F1\",\"guardId\":12147,\"guardName\":\"8栋负一正门\",\"code\":\"20190524172033\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8158,\"version\":\"32\",\"secretKey\":\"N86d6EQUg2ZYCSx2YnISDw\",\"macAddress\":\"40:BD:32:AF:AC:1D\",\"guardId\":6763,\"guardName\":\"东门单车行道\",\"code\":\"20181017180546\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15783,\"version\":\"32\",\"secretKey\":\"9f5nQRvq0NDiustLjob1jA\",\"macAddress\":\"B0:7E:11:ED:EB:B0\",\"guardId\":12146,\"guardName\":\"8栋负二正门\",\"code\":\"20190524170302\",\"supplierType\":\"1\",\"orderNum\":5},\"keyType\":\"01\"}],\"url\":\"semtec-ss1\"}}"];
        [array addObject:@"{\"encrypt\":true,\"code\":10000,\"desc\":\"请求执行成功！\",\"rts\":\"0000000000\",\"result\":{\"keys\":[{\"blueToothDeviceVo\":{\"deviceId\":15785,\"version\":\"32\",\"secretKey\":\"uQ0uIglyUOaqXjv//F+now\",\"macAddress\":\"B0:7E:11:F4:D9:D1\",\"guardId\":12148,\"guardName\":\"9栋负一正门\",\"code\":\"20190524173555\",\"supplierType\":\"1\",\"orderNum\":0},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":10860,\"version\":\"32\",\"secretKey\":\"i+pzrxp8LtsIKAJnphOupw\",\"macAddress\":\"30:45:11:6B:9E:80\",\"guardId\":8471,\"guardName\":\"9栋大堂\",\"code\":\"20181127160712\",\"supplierType\":\"1\",\"orderNum\":1},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8156,\"version\":\"32\",\"secretKey\":\"nxzKBFmHUq+FJ9qm3kBE+A\",\"macAddress\":\"40:BD:32:AF:A5:FD\",\"guardId\":6765,\"guardName\":\"北门\",\"code\":\"20181017164904\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8157,\"version\":\"32\",\"secretKey\":\"Il3ITyDWG4gL4axaXtN9VA\",\"macAddress\":\"50:F1:4A:F8:79:3A\",\"guardId\":6764,\"guardName\":\"西门\",\"code\":\"20181017172830\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15786,\"version\":\"32\",\"secretKey\":\"C2NmSxiMnKxuXN9jvV1c0w\",\"macAddress\":\"B0:7E:11:F4:F3:87\",\"guardId\":12149,\"guardName\":\"9栋负二正门\",\"code\":\"20190524174920\",\"supplierType\":\"1\",\"orderNum\":5},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8158,\"version\":\"32\",\"secretKey\":\"N86d6EQUg2ZYCSx2YnISDw\",\"macAddress\":\"40:BD:32:AF:AC:1D\",\"guardId\":6763,\"guardName\":\"东门单车行道\",\"code\":\"20181017180546\",\"supplierType\":\"1\",\"orderNum\":5},\"keyType\":\"01\"}],\"url\":\"semtec-ss1\"}}"];
        [array addObject:@"{\"encrypt\":true,\"code\":10000,\"desc\":\"请求执行成功！\",\"rts\":\"0000000000\",\"result\":{\"keys\":[{\"blueToothDeviceVo\":{\"deviceId\":10861,\"version\":\"32\",\"secretKey\":\"oG+JhF+V7lRsE2Vyf35vDA\",\"macAddress\":\"40:BD:32:B0:56:94\",\"guardId\":8472,\"guardName\":\"10栋大堂\",\"code\":\"20181127155104\",\"supplierType\":\"1\",\"orderNum\":0},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15788,\"version\":\"32\",\"secretKey\":\"OCggpfkEmJQ4muZgyZoVog\",\"macAddress\":\"B0:7E:11:F5:05:92\",\"guardId\":12151,\"guardName\":\"10栋负一正门\",\"code\":\"20190525091056\",\"supplierType\":\"1\",\"orderNum\":1},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8156,\"version\":\"32\",\"secretKey\":\"nxzKBFmHUq+FJ9qm3kBE+A\",\"macAddress\":\"40:BD:32:AF:A5:FD\",\"guardId\":6765,\"guardName\":\"北门\",\"code\":\"20181017164904\",\"supplierType\":\"1\",\"orderNum\":2},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8157,\"version\":\"32\",\"secretKey\":\"Il3ITyDWG4gL4axaXtN9VA\",\"macAddress\":\"50:F1:4A:F8:79:3A\",\"guardId\":6764,\"guardName\":\"西门\",\"code\":\"20181017172830\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8158,\"version\":\"32\",\"secretKey\":\"N86d6EQUg2ZYCSx2YnISDw\",\"macAddress\":\"40:BD:32:AF:AC:1D\",\"guardId\":6763,\"guardName\":\"东门单车行道\",\"code\":\"20181017180546\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15787,\"version\":\"32\",\"secretKey\":\"UYKzPLik4oW+NGmEzsIy5Q\",\"macAddress\":\"B0:7E:11:E9:EC:E4\",\"guardId\":12150,\"guardName\":\"10栋负二正门\",\"code\":\"20190525085015\",\"supplierType\":\"1\",\"orderNum\":5},\"keyType\":\"01\"}],\"url\":\"semtec-ss1\"}}"];
        [array addObject:@"{\"encrypt\":true,\"code\":10000,\"desc\":\"请求执行成功！\",\"rts\":\"0000000000\",\"result\":{\"keys\":[{\"blueToothDeviceVo\":{\"deviceId\":10862,\"version\":\"32\",\"secretKey\":\"FC0qSpC/3lmTT7sDv8L4zg\",\"macAddress\":\"40:BD:32:AE:B9:BF\",\"guardId\":8473,\"guardName\":\"11栋大堂\",\"code\":\"20181127112154\",\"supplierType\":\"1\",\"orderNum\":1},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8156,\"version\":\"32\",\"secretKey\":\"nxzKBFmHUq+FJ9qm3kBE+A\",\"macAddress\":\"40:BD:32:AF:A5:FD\",\"guardId\":6765,\"guardName\":\"北门\",\"code\":\"20181017164904\",\"supplierType\":\"1\",\"orderNum\":2},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15789,\"version\":\"32\",\"secretKey\":\"luWURvCYIZa3jDBZjcot2Q\",\"macAddress\":\"B0:7E:11:F4:DD:B2\",\"guardId\":12152,\"guardName\":\"11栋负一正门\",\"code\":\"20190525103522\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8157,\"version\":\"32\",\"secretKey\":\"Il3ITyDWG4gL4axaXtN9VA\",\"macAddress\":\"50:F1:4A:F8:79:3A\",\"guardId\":6764,\"guardName\":\"西门\",\"code\":\"20181017172830\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8158,\"version\":\"32\",\"secretKey\":\"N86d6EQUg2ZYCSx2YnISDw\",\"macAddress\":\"40:BD:32:AF:AC:1D\",\"guardId\":6763,\"guardName\":\"东门单车行道\",\"code\":\"20181017180546\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15790,\"version\":\"32\",\"secretKey\":\"ro9/NZwNyrgSH1AONFHB+Q\",\"macAddress\":\"B0:7E:11:F5:01:58\",\"guardId\":12153,\"guardName\":\"11栋负二正门\",\"code\":\"20190525110040\",\"supplierType\":\"1\",\"orderNum\":5},\"keyType\":\"01\"}],\"url\":\"semtec-ss1\"}}"];
        [array addObject:@"{\"encrypt\":true,\"code\":10000,\"desc\":\"请求执行成功！\",\"rts\":\"0000000000\",\"result\":{\"keys\":[{\"blueToothDeviceVo\":{\"deviceId\":10863,\"version\":\"32\",\"secretKey\":\"QLm7aQrg7CNyixFQZQbKfA\",\"macAddress\":\"40:BD:32:AF:98:C2\",\"guardId\":8474,\"guardName\":\"12栋大堂\",\"code\":\"20181127152023\",\"supplierType\":\"1\",\"orderNum\":0},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15792,\"version\":\"32\",\"secretKey\":\"NNd6v7Jlj8TBHvQWvNyHgQ\",\"macAddress\":\"B0:7E:11:F4:E9:6F\",\"guardId\":12155,\"guardName\":\"12栋负一正门\",\"code\":\"20190525114141\",\"supplierType\":\"1\",\"orderNum\":1},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8156,\"version\":\"32\",\"secretKey\":\"nxzKBFmHUq+FJ9qm3kBE+A\",\"macAddress\":\"40:BD:32:AF:A5:FD\",\"guardId\":6765,\"guardName\":\"北门\",\"code\":\"20181017164904\",\"supplierType\":\"1\",\"orderNum\":2},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8157,\"version\":\"32\",\"secretKey\":\"Il3ITyDWG4gL4axaXtN9VA\",\"macAddress\":\"50:F1:4A:F8:79:3A\",\"guardId\":6764,\"guardName\":\"西门\",\"code\":\"20181017172830\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15791,\"version\":\"32\",\"secretKey\":\"PU47G9U2CT49M/Sn5cOj1w\",\"macAddress\":\"B0:7E:11:F4:D5:88\",\"guardId\":12154,\"guardName\":\"12栋负二正门\",\"code\":\"20190525112230\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8158,\"version\":\"32\",\"secretKey\":\"N86d6EQUg2ZYCSx2YnISDw\",\"macAddress\":\"40:BD:32:AF:AC:1D\",\"guardId\":6763,\"guardName\":\"东门单车行道\",\"code\":\"20181017180546\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":10856,\"version\":\"32\",\"secretKey\":\"VpAPKk9IW8ABkiI7bWvNGQ\",\"macAddress\":\"30:45:11:6B:A3:C4\",\"guardId\":8466,\"guardName\":\"4栋大堂\",\"code\":\"20181128102230\",\"supplierType\":\"1\",\"orderNum\":5},\"keyType\":\"01\"}],\"url\":\"semtec-ss1\"}}"];
        for(NSString *json in array) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *result = [response objectForKey:@"result"];
            for(NSDictionary *key in [result objectForKey:@"keys"]) {
                NSDictionary *vo = [key objectForKey:@"blueToothDeviceVo"];
                NSString *macAddress = [vo objectForKey:@"macAddress"];
                if([self.keys valueForKey:macAddress]) {
                    continue;
                }
                NSString *guardName = [vo objectForKey:@"guardName"];
                NSString *secretKey = [vo objectForKey:@"secretKey"];
                BleKey *key = [[BleKey alloc] init:secretKey name:guardName];
                [self.keys setValue:key forKey:macAddress];
            }
        }
    }
    return self;
}

@end
