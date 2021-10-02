const TileNFT = artifacts.require("TileNFT");

module.exports = async function (deployer) {
    let tileData = 
    [
        [206242393133,274945094174,343664573197,206225615402,137522914869,412367273548,343647794952,137506137399,274928316219,281268902307337,281337621783561,281337605006406,281268885530652,281406324482567,281406341260034,281200166055436,67248695,281337588229457,281268868753968,84026117], 
        [281406307705381,68786725632,281406358037250,50471430,281200149279503,68769948172,137489425427,68803502871,281131362832671,281062660133154,281062676910145,281131379606532,100672301,68820149296,281337571321181,281131446449461,33563179,281337554543888,281268851846211,281200132372010],
        [281131429673992,281062710199809,206208772372,137472517213,68753039897,16785709,281337537766717,281268835069191,281200115595008,281131412898117,281062693424480,274911472984,206191994626,137455739697,68736262657,8495,412350429792,343630951427,274894695446,206175217421],
        [137438962436,68719485461,68702708226,281406290797124,281406274019870,281406257242631,281406240466509,281268818292020,281200098817835,412333652023,343614173712,274877918251,206158440215,206141662252,137422184980,68685931828,281474959942439,206124885853,274844363082,206108109843],
        [281131396121632,412316874766,343597396508,343580617733,274861139737,481019574313,412300096023,343563840822,343547064341,412266541624,481002796896,412283318859,480986018908,137406522644,137389747204,68670270491,137372972316,281474944280136,281131346908000,281200083223592], 
        [281200066446923,281268802697265,281131330196993,281268785920566,281337522171199,281200049670918,281268752500510,281268769275916,281337471975176,281337488487969,281406191188238,281406174413842,281337505263690,281406207962933,281474927438888,281474910664200,68636655883,281474893890051,281406224738653,68653430274],
        [137356132640,68619881748,206092383543,206075608885,274828635668,274811860001,343531336460]
    ];
    

    let instance = await TileNFT.deployed();
    for(element of tileData) {
        await instance.addTiles(element);
    }
}