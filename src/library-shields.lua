Shields = (function()
  local this = {
    disabled = false,
    template = 
  }

  function this.init(s)

  end

  function this.keyAction(s)

  return this
end)()


-- also has ship HP section in it

HUD.widgets.shields =  {
  init = function(s)
    s.tmpl = Template.new(s.template)
    s.tmpl:listen(function(data)
      s.html = data.html;
    end);
    HUD.full.widgets['shields'] = 'on'
  end,
  html = "",
  template = [[
  <div class="hud-shields">
    <svg viewBox="0 0 540 75">
      <path d="M 52.4 71.9 L 42.4 61.3 L 31.8 61.3 L 34.8 59 L 80.5 59 L 90.2 69.5 L 87.8 72 L 52.4 71.9 Z" style="fill: rgb(45, 72, 92); fill-opacity: 0.88; stroke-width: 6.79717px; stroke-miterlimit: 6;" transform="matrix(-1, 0, 0, -1, 122, 131)"/>
      <g transform="matrix(-0.07356, 0, 0, 0.07356, 108.27914, -11.85233)">
        <polygon style="fill: rgb(45, 72, 92); fill-opacity: 0.88;" points="-1483.199951171875 216.3000030517578 328.3999938964844 217.8000030517578 420.1000061035156 306.5 1224.300048828125 305.79998779296875 1431.0999755859375 506 1340.199951171875 588.9000244140625 -6.400000095367432 589.5999755859375 -94.4000015258789 674.7000122070312 -1453.9000244140625 675.4000244140625 -1585.9000244140625 544.0999755859375 -1584.5 317.3999938964844" transform="matrix(-1, 0, 0, -1, -165, 887.39999)"/>
        <path d="M -1604.4 379.6 L -1591.9 382.5 L -1502.2 302.7 L -154.1 303 L -67.5 216.2 L 1284.4 216.3 L 1416.6 348 L 1416.2 567.7 L 1316.4 667.5 L -492.3 667.2 L -581.9 577.8 L -1386.8 578.2 L -1591.4 377.8 L -1604.2 379.6 L -1393.4 587 L -586.7 587 L -496.7 677 L 1321.4 677 L 1426.6 571.8 L 1426.6 342.9 L 1290.4 206.8 L -72.4 206.8 L -159.3 293.7 L -1508 293.7 L -1604.4 379.6 Z" class="fil1" style="fill: rgb(73, 146, 207);"/>
        <polygon class="fil1" points="-105.8 304.2 -44.6 243.1 77.2 243.1 15.4 304.9" style="fill: rgb(73, 146, 207);"/>
        <polygon class="fil1" points="79.7 304.2 140.8 243.1 262.7 243.1 200.9 304.9" style="fill: rgb(73, 146, 207);"/>
        <polygon class="fil1" points="265.2 304.2 326.3 243.1 448.2 243.1 386.3 304.9" style="fill: rgb(73, 146, 207);"/>
        <polygon class="fil1" points="450.7 304.2 511.8 243.1 633.7 243.1 571.8 304.9" style="fill: rgb(73, 146, 207);"/>
        <polygon class="fil1" points="636.2 304.2 697.3 243.1 819.2 243.1 757.3 304.9" style="fill: rgb(73, 146, 207);"/>
        <polygon class="fil1" points="821.6 304.2 882.8 243.1 1004.6 243.1 942.8 304.9" style="fill: rgb(73, 146, 207);"/>
        <polygon class="fil1" points="1007.1 304.2 1068.2 243.1 1190.1 243.1 1128.3 304.9" style="fill: rgb(73, 146, 207);"/>
        <polygon class="fil1" points="1179.6 304.2 1240.7 243.1 1267.6 243.1 1323.9 304.9" style="fill: rgb(73, 146, 207);"/>
        <path class="fil1" d="M -1402.3 527.6 L 144.1 527.6 L 181.2 566.7 L 1381.4 566.7 L 1304.8 643.3 C 1304.8 643.3 -480.9 645.8 -480.9 643.3 C -480.9 640.7 -564.4 557.7 -567.2 554.9 C -570 552.1 -1374.7 554.9 -1374.7 554.9 L -1402.3 527.6 Z" style="fill: rgb(73, 146, 207);"/>
        <path class="fil1" d="M 1447.1 516 C 1447.1 516.6 1447.1 585.5 1447.1 585.5 L 1450.8 585.5 L 1448.2 582.8 L 1411.8 619.2 L 1417.1 624.5 L 1454.5 587 L 1454.5 585.5 C 1454.5 585.5 1454.5 516.6 1454.5 516 L 1447.1 516 Z" style="fill: rgb(73, 146, 207);"/>
        <polygon class="fil1" points="-122.5 222.1 -86.1 185.8 86.3 185.8 86.3 178.3 -89.2 178.3 -127.8 216.9" style="fill: rgb(73, 146, 207);"/>
        <text class="fttu c-co" style="font-family:Bank; font-size: 150; font-weight:700; letter-spacing:-1.3vh; line-height: 328px;" transform="matrix(-1, 0, 0, 1, 0, 0)" x="-1340.2" y="473.3">{{ShipName}}</text>
        <path class="fil1" d="M -932.3 769.4 L -1058 896.4 L 563.8 897.6 L 686.6 769.4 L -932.3 769.4 Z" style="fill: rgb(73, 146, 207);"/>
        <polygon style="fill-opacity: 0.88; fill: rgb(45, 72, 92);" points="-1032.2 885.6 -925.5 778.9 323 777.7 218.9 886.7"/>
        <path d="M -988.1 868.7 L -914.7 796.6 L 278.9 796.6 L 209.7 867.4 L -988.1 868.7 Z" style="fill: rgb(197, 103, 103); stroke-miterlimit: 1; paint-order: fill;"/>
        <text class="fttu ftam c-th" style="font-size: 112.349px; font-weight: 700; letter-spacing: -0.1px; line-height: 195.759px;" transform="matrix(-1, 0, 0, 1, 0, 0)" x="-448.7" y="873.5">100%</text>
        <polygon style="stroke: rgb(0, 0, 0); fill: rgb(49, 81, 106);" points="843.1 769.6"/>
        <path class="c-bg" d="M 709.9 769.6 L 572.9 914 L 430 914 L 470.6 946.2 L 1091.5 945.2 L 1223.8 802.4 L 1190.8 769.4 L 709.9 769.6 Z" style=" fill-opacity: 0.88; stroke-width: 6.79717px; stroke-miterlimit: 6;"/>
        <text class="ftam fttu c-co" style="font-size: 135.943px; letter-spacing: -0.1px; line-height: 195.759px;" transform="matrix(-1, 0, 0, 1, 0, 0)" x="-906.3" y="901.9">SHIP HP</text>
        <path class="fil1" d="M -1115.1 965 L -1240.8 1092 L 381 1093.2 L 503.8 965 L -1115.1 965 Z" style="fill: rgb(73, 146, 207);"/>
        <polygon style="fill-opacity: 0.88; fill: rgb(45, 72, 92);" points="-1215 1081.2 -1108.3 974.5 140.2 973.3 36.1 1082.3"/>
        <path class="c-bg" d="M -1170.9 1064.3 L -1097.5 992.2 L 96.1 992.2 L 26.9 1063 L -1170.9 1064.3 Z" stroke-miterlimit: 1; paint-order: fill;"/>
        <text class="ftam fttu c-th" style="font-size: 112.349px; font-weight: 700; letter-spacing: -0.1px; line-height: 195.759px;" transform="matrix(-1, 0, 0, 1, 0, 0)" x="-263.5" y="1071.5">{{HPStressPerc}}%</text>
        <text class="ftam fttu c-co" style="font-size: 135.943px; letter-spacing: -0.1px; line-height: 195.759px;" transform="matrix(-1, 0, 0, 1, 0, 0)" x="-717.6" y="1096.9">STRESS</text>
      </g>
      <g transform="matrix(1, 0, 0, 1, -34.99598, -320.55222)">
        <path class="fil1" d="M 207.7 360.3 L 210.7 360.3 L 212.2 357.7 L 210.7 355 L 207.7 355 L 206.2 357.7 L 207.7 360.3 Z M 211.1 361 L 207.3 361 L 205.4 357.7 L 207.3 354.3 L 211.1 354.3 L 213 357.7 L 211.1 361 Z" style="fill: rgb(73, 146, 207);"/>
        <polygon class="fil1" points="210.3 355.7 208.1 355.7 207 357.7 208.1 359.6 210.3 359.6 211.4 357.7" style="fill: rgb(73, 146, 207);"/>
        <polygon class="fil1" points="252.3 358 209.9 358 209.9 357.3 252 357.3 274.4 334.8 274.9 335.3" style="fill: rgb(73, 146, 207);"/>
        <path class="fil1" d="M 277.7 335.1 C 277.7 336.8 276.4 338.1 274.7 338.1 C 273 338.1 271.6 336.8 271.6 335.1 C 271.6 333.4 273 332 274.7 332 C 276.4 332 277.7 333.4 277.7 335.1 Z" style="fill: rgb(73, 146, 207);"/>
      </g>
      
      <g transform="matrix(1.10499, 0, 0, 1.10499, -78.55247, -361.41434)">
        <path class="fil1" d="M 476.1 362.2 L 455.1 341.2 L 537 341.2 L 557.7 362.1 L 556.9 362.1 L 476.1 362.2 Z" style="fill: rgb(73, 146, 207); fill-opacity: 0.6;"/>
        <polygon class="fil1" points="496.8 365.5 475.1 365.5 469.1 359.5 469.6 359 475.4 364.8 496.8 364.8" style="fill: rgb(73, 146, 207);"/>
        <path class="fil1" d="M 476.1 368.2 L 455.1 389.2 L 537 389.2 L 557.7 368.3 L 556.9 368.3 L 476.1 368.2 Z" style="fill: rgb(73, 146, 207); fill-opacity: 0.6;"/>
        <polygon class="fil1" points="469.6 371.3 469.1 370.8 474.9 364.9 475.5 365.4" style="fill: rgb(73, 146, 207);"/>
        <polygon class="fil2" points="522.1 343.3 532.8 354 538.7 354 528 343.3" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);"/>
        <polygon class="fil2" points="529.7 343.3 540.4 354 546.3 354 535.6 343.3" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);"/>
        <polygon class="fil1" points="460.8 343.3 471.5 354 477.5 354 466.7 343.3" style="fill: rgb(218, 239, 255);"/>
        <polygon class="fil1" points="468.5 343.3 479.2 354 485.1 354 474.4 343.3" style="fill: rgb(218, 239, 255);"/>
        <polygon class="fil1" points="476.1 343.3 486.8 354 492.8 354 482.1 343.3" style="fill: rgb(218, 239, 255);"/>
        <polygon class="fil1" points="483.8 343.3 494.5 354 500.4 354 489.7 343.3" style="fill: rgb(218, 239, 255);"/>
        <polygon class="fil1" points="491.4 343.3 502.1 354 508.1 354 497.4 343.3" style="fill: rgb(218, 239, 255);"/>
        <polygon class="fil1" points="499.1 343.3 509.8 354 515.8 354 505 343.3" style="fill: rgb(218, 239, 255);"/>
        <polygon class="fil2" points="506.8 343.3 517.5 354 523.4 354 512.7 343.3" style="fill: rgb(218, 239, 255);"/>
        <polygon class="fil2" points="514.4 343.3 525.1 354 531.1 354 520.4 343.3" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);"/>
        <polygon style="fill: rgb(4, 29, 47); fill-opacity: 0.7;" points="470.8 355.9 476.5 361.6 556.4 361.6 550.7 355.9"/>
        <path d="M 473.6 356.9 L 477.2 360.5 L 541.1 360.5 L 537.5 357 L 473.6 356.9 Z" style="fill: rgb(197, 103, 103); stroke-miterlimit: 1; paint-order: fill;"/>
        <polygon class="fil2" points="522.1 387.1 532.8 376.4 538.7 376.4 528 387.1" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);"/>
        <polygon class="fil2" points="529.7 387.1 540.4 376.4 546.3 376.4 535.6 387.1" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);"/>
        <polygon class="fil1" points="460.8 387.1 471.5 376.4 477.5 376.4 466.7 387.1" style="fill: rgb(218, 239, 255);"/>
        <polygon class="fil1" points="468.5 387.1 479.2 376.4 485.1 376.4 474.4 387.1" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);"/>
        <polygon class="fil1" points="476.1 387.1 486.8 376.4 492.8 376.4 482.1 387.1" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);"/>
        <polygon class="fil1" points="483.8 387.1 494.5 376.4 500.4 376.4 489.7 387.1" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);"/>
        <polygon class="fil1" points="491.4 387.1 502.1 376.4 508.1 376.4 497.4 387.1" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);"/>
        <polygon class="fil1" points="499.1 387.1 509.8 376.4 515.8 376.4 505 387.1" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);"/>
        <polygon class="fil2" points="506.8 387.1 517.5 376.4 523.4 376.4 512.7 387.1" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);"/>
        <polygon class="fil2" points="514.4 387.1 525.1 376.4 531.1 376.4 520.4 387.1" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);"/>
        <polygon style="fill-opacity: 0.7; fill: rgb(4, 29, 47);" points="470.8 374.5 476.5 368.8 556.4 368.8 550.7 374.5"/>
        <path d="M 473.6 373.5 L 477.2 369.9 L 487.6 369.9 L 484 373.4 L 473.6 373.5 Z" style="fill: rgb(197, 103, 103); stroke-miterlimit: 1; paint-order: fill;"/>
        <path class="fil1" d="M 299.1 341.2 L 278.1 362.2 L 360 362.2 L 380.7 341.3 L 379.9 341.3 L 299.1 341.2 Z" style="fill: rgb(73, 146, 207); fill-opacity: 0.6;" transform="matrix(-1, 0, 0, -1, 658.80002, 703.40002)"/>
        <polygon class="fil1" points="366.7 359 345 359 339 365 339.5 365.5 345.3 359.7 366.7 359.7" style="fill: rgb(73, 146, 207);" transform="matrix(-1, 0, 0, -1, 705.70001, 724.5)"/>
        <path class="fil1" d="M 299.1 389.2 L 278.1 368.2 L 360 368.2 L 380.7 389.1 L 379.9 389.1 L 299.1 389.2 Z" style="fill: rgb(73, 146, 207); fill-opacity: 0.6;" transform="matrix(-1, 0, 0, -1, 658.80002, 757.40002)"/>
        <polygon class="fil1" points="360.8 364.9 360.3 365.4 366.1 371.3 366.7 370.8" style="fill: rgb(73, 146, 207);" transform="matrix(-1, 0, 0, -1, 727, 736.19998)"/>
        <polygon class="fil2" points="297.1 354 307.8 343.3 313.7 343.3 303 354" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 610.80002, 697.29999)"/>
        <polygon class="fil2" points="289.5 354 300.2 343.3 306.1 343.3 295.4 354" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 595.60001, 697.29999)"/>
        <polygon class="fil1" points="358.3 354 369 343.3 375 343.3 364.2 354" style="fill-opacity: 0.8; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 733.29999, 697.29999)"/>
        <polygon class="fil1" points="350.7 354 361.4 343.3 367.3 343.3 356.6 354" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 718, 697.29999)"/>
        <polygon class="fil1" points="343 354 353.7 343.3 359.7 343.3 349 354" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 702.70001, 697.29999)"/>
        <polygon class="fil1" points="335.4 354 346.1 343.3 352 343.3 341.3 354" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 687.39999, 697.29999)"/>
        <polygon class="fil1" points="327.7 354 338.4 343.3 344.4 343.3 333.7 354" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 672.10001, 697.29999)"/>
        <polygon class="fil1" points="320 354 330.7 343.3 336.7 343.3 325.9 354" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 656.70001, 697.29999)"/>
        <polygon class="fil2" points="312.4 354 323.1 343.3 329 343.3 318.3 354" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 641.39999, 697.29999)"/>
        <polygon class="fil2" points="304.7 354 315.4 343.3 321.4 343.3 310.7 354" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 626.10001, 697.29999)"/>
        <polygon style="fill: rgb(4, 29, 47); fill-opacity: 0.7;" points="279.4 361.6 285.1 355.9 365 355.9 359.3 361.6" transform="matrix(-1, 0, 0, -1, 644.39999, 717.5)"/>
        <path d="M 352.8 360.5 L 356.4 356.9 L 362.2 356.9 L 358.6 360.4 L 352.8 360.5 Z" style="fill: rgb(197, 103, 103); stroke-miterlimit: 1; paint-order: fill;" transform="matrix(-1, 0, 0, -1, 715, 717.39999)"/>
        <polygon class="fil2" points="297.1 376.4 307.8 387.1 313.7 387.1 303 376.4" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 610.80002, 763.5)"/>
        <polygon class="fil2" points="289.5 376.4 300.2 387.1 306.1 387.1 295.4 376.4" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 595.60001, 763.5)"/>
        <polygon class="fil1" points="358.3 376.4 369 387.1 375 387.1 364.2 376.4" style="fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 733.29999, 763.5)"/>
        <polygon class="fil1" points="350.7 376.4 361.4 387.1 367.3 387.1 356.6 376.4" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 718, 763.5)"/>
        <polygon class="fil1" points="343 376.4 353.7 387.1 359.7 387.1 349 376.4" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 702.70001, 763.5)"/>
        <polygon class="fil1" points="335.4 376.4 346.1 387.1 352 387.1 341.3 376.4" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 687.39999, 763.5)"/>
        <polygon class="fil1" points="327.7 376.4 338.4 387.1 344.4 387.1 333.7 376.4" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 672.10001, 763.5)"/>
        <polygon class="fil1" points="320 376.4 330.7 387.1 336.7 387.1 325.9 376.4" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 656.70001, 763.5)"/>
        <polygon class="fil2" points="312.4 376.4 323.1 387.1 329 387.1 318.3 376.4" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 641.39999, 763.5)"/>
        <polygon class="fil2" points="304.7 376.4 315.4 387.1 321.4 387.1 310.7 376.4" style="fill-opacity: 0.2; fill: rgb(218, 239, 255);" transform="matrix(-1, 0, 0, -1, 626.10001, 763.5)"/>
        <polygon style="fill: rgb(4, 29, 47); fill-opacity: 0.7;" points="279.4 368.8 285.1 374.5 365 374.5 359.3 368.8" transform="matrix(-1, 0, 0, -1, 644.39999, 743.29999)"/>
        <path d="M 339.8 369.9 L 343.4 373.5 L 362.2 373.5 L 358.6 370 L 339.8 369.9 Z" style="fill: rgb(197, 103, 103); stroke-miterlimit: 1; paint-order: fill;" transform="matrix(-1, 0, 0, -1, 702, 743.39999)"/>
        <polygon style="stroke-width: 2px; stroke-miterlimit: 1; fill: rgb(45, 72, 92); fill-opacity: 0.88;" points="364.1 365.1 387.9 341.3 447.7 341.2 471.8 365 447.9 389.2 388.4 389.2"/>
        <path d="M 468.3 353.9 L 457.7 343.2 L 437.4 343.2 L 447.9 353.9 L 468.3 353.9 Z" style="fill: rgb(73, 146, 207);"/>
        <text class="c-th ffro fls1 ftam fttu" style="font-size: 7.5px; font-weight: 700;" x="452.9" y="351.4">KIN</text>
        <path d="M 468.3 376.4 L 457.7 387.1 L 437.4 387.1 L 447.9 376.4 L 468.3 376.4 Z" style="fill: rgb(73, 146, 207);"/>
        <text class="c-th ffro fls1 ftam fttu" style="font-size: 7.5px; font-weight: 700;" x="450.8" y="384.7">ANTI</text>
        <path d="M 398.3 343.2 L 387.7 353.9 L 367.4 353.9 L 377.9 343.2 L 398.3 343.2 Z" style="fill: rgb(73, 146, 207);" transform="matrix(-1, 0, 0, -1, 765.69998, 697.10001)"/>
        <path d="M 398.3 387.1 L 387.7 376.4 L 367.4 376.4 L 377.9 387.1 L 398.3 387.1 Z" style="fill: rgb(73, 146, 207);" transform="matrix(-1, 0, 0, -1, 765.69998, 763.5)"/>
        <text class="c-th ffro fls1 ftam fttu" style="font-size: 7.5px; font-weight: 700;" x="382.8" y="351.4">ELC</text>
        <text class="c-th ffro fls1 ftam fttu" style="font-size: 7.5px; font-weight: 700;" x="382.1" y="384.6">THR</text>
        <text class="c-th ffro fls1 ftam" style="font-size: 13px; font-weight: 700;" x="418.3" y="354.2">100%</text>
        <path d="M 370.2 358.4 L 363.5 365 L 369.6 371.1 L 466.2 371.2 L 472.4 364.9 L 465.8 358.5 Z" style="fill: rgb(183, 181, 101);"/>
        <text class="c-th ffro fls1 ftam fttu" style="font-size: 9px; font-weight: 700;" x="418.2" y="367.7">VENTING 1:19</text>
        <text class="ffro fls1 ftam fttu" style="fill: rgb(172, 188, 204); font-size: 6px; font-weight: 700;" x="417.3" y="378.6">VENT 1:19</text>
        <text class="ffro fls1 ftam fttu" style="fill: rgb(172, 188, 204); font-size: 6px; font-weight: 700;" x="418.1" y="385.5">RESISTS 1:19</text>
      </g>
      
    </svg>
  </div>
  ]]
};