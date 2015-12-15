//
//  Settings.swift
//  HopeFM
//
//  Created by Sergey Sadovoi on 15.12.15.
//  Copyright © 2016 Hope Media Group Ukraine. All rights reserved.
//

struct Config {
    struct Stream {
        static let Url  = "http://stream.hope.ua:7777/hope.fm/128"
        static let Info = "http://stream.hope.ua:7777/currentsong?sid=21"
    }
    
    struct Urls {
        static let Website  = "http://radio.hope.ua"
        static let Facebook = "https://www.facebook.com/golosnadii"
        static let Twitter  = "https://twitter.com/golosnadii"
        struct Vk {
            static let App     = "vk://vk.com/golosnadii"
            static let Browser = "https://vk.com/golosnadii"
        }
        static let Podster  = "http://podster.fm/user/golosnadii"
    }
}
