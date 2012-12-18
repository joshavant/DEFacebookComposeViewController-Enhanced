# [DEFacebookComposeViewController](https://github.com/sakrist/FacebookSample)-Enhanced

**Modified to add delegation and ARC support.**

![image](http://iamjo.sh/github-images/defacebookcomposeviewcontroller_enhanced/screenshot.jpg)

## Overview
This is a quick modification of [DEFacebookComposeViewController](https://github.com/sakrist/FacebookSample), adding delegation and ARC support.


## Discussion

Added delegate support to [DEFacebookComposeViewController](https://github.com/sakrist/FacebookSample) so Facebook publishing calls are abstracted from this library to the delegate.

Additionally, removed the iOS 6 check so it does not fallback to SLComposeViewController. (This is done because posts through SLComposeViewController show up as 'via iOS' on Facebook, and not 'via' your Facebook app name.)

Finally, it was ARCified.

Sample implementation suggestions are provided in code comments in DEFacebookComposeViewController.h.


## Compatibility
* iOS 4.3+
* ARC


**Contributions, corrections, and improvements are always appreciated!**

## Created By
Josh Avant

## License
This is licensed under a MIT/Beerware License:

    Copyright (c) 2012 Josh Avant

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.

    If we meet some day, and you think this stuff is worth it, you can buy me a
    beer in return.