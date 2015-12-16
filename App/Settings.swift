//
//  Settings.swift
//  HopeFM
//
//  Created by Sergey Sadovoi on 15.12.15.
//  Copyright © 2016 Hope Media Group Ukraine. All rights reserved.
//

import Foundation

struct Config {
    struct Stream {
        static let Url  = NSURL(string: "http://stream.hope.ua:1935/hopefm/ngrp:live/playlist.m3u8")
        static let Info = NSURL(string: "http://stream.hope.ua:7777/currentsong?sid=21")
    }
    
    struct Urls {
        static let Website  = NSURL(string: "http://radio.hope.ua")
        static let Facebook = NSURL(string: "https://www.facebook.com/golosnadii")
        static let Twitter  = NSURL(string: "https://twitter.com/golosnadii")
        struct Vk {
            static let App     = NSURL(string: "vk://vk.com/golosnadii")
            static let Browser = NSURL(string: "https://vk.com/golosnadii")
        }
        static let Podster = NSURL(string: "http://podster.fm/user/golosnadii")
    }
}
