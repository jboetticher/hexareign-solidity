const TileNFT = artifacts.require("TileNFT");

module.exports = async function (deployer) {
    let tileData = 
    [
        [206242398208,274945097728,343664574464,206225620992,137522921472,412367273984,343647797248,137506144256,274928320512,281268902313984,281337621790720,281337605013504,281268885536768,281406324490240,281406341267456,281200166060032,67256320,281337588236288,281268868759552,84033536,281406307713024,68786733056,281406358044672,50479104,281200149282816,68769955840,137489432576,68803510272,281131362828288,281062660128768,281062676905984,281131379605504,100679680,68820156416,281337571328000,281131446452224,33570816,281337554550784,281268851851264,281200132374528], 
        [281131429675008,281062710198272,206208778240,137472524288,68753047552,16793600,281337537773568,281268835074048,281200115597312,281131412897792,281062693421056,274911477760,206192001024,137455747072,68736270336,16384,412350431232,343630954496,274894700544,206175223808,137438969856,68719493120,68702715904,281406290804736,281406274027520,281406257250304,281406240473088,281268818296832,281200098820096,412333654016,343614177280,274877923328,206158446592,206141669376,137422192640,68685938688,281474959949824,206124892160,274844368896,206108114944], 
        [281131396120576,412316876800,343597400064,343580622848,274861146112,481019576320,412300099584,343563845632,343547068416,412266545152,481002799104,412283322368,480986021888,137406529536,137389752320,68670275584,137372975104,281474944286720,281131346903040,281200083222528,281200066445312,281268802699264,281131330191360,281268785922048,281337522176000,281200049668096,281268752498688,281268769275904,281337471975424,281337488490496,281406191190016,281406174412800,281337505267712,281406207967232,281474927443968,281474910666752,68636655616,281474893889536,281406224744448,68653432832], 
        [137356132352,68619878400,206092386304,206075609088,274828640256,274811863040,343531339776]
    ];

    let instance = await TileNFT.deployed();
    for(element of tileData) {
        await instance.addTiles(element);
    }
}