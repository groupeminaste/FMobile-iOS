//
//  CarrierIdentification.swift
//  FMobile
//
//  Created by PlugN on 26/03/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation

class CarrierIdentification {

    static func getIsoCountryCode (_ country : String, _ mnc : String) -> String {
        let dictCodes = [
            "412" : "AF",
            "276" : "AL",
            "603" : "DZ",
            "544" : "AS",
            "213" : "AD",
            "631" : "AO",
            "365" : "AI",
            "344" : "AG",
            "722" : "AR",
            "283" : "AM",
            "363" : "AW",
            "505" : "AU",
            "232" : "AT",
            "400" : "AZ",
            "364" : "BS",
            "426" : "BH",
            "470" : "BD",
            "342" : "BB",
            "257" : "BY",
            "206" : "BE",
            "702" : "BZ",
            "616" : "BJ",
            "350" : "BM",
            "402" : "BT",
            "218" : "BA",
            "652" : "BW",
            "724" : "BR",
            "995" : "IO",
            "284" : "BG",
            "613" : "BF",
            "642" : "BI",
            "456" : "KH",
            "624" : "CM",
            "302" : "CA",
            "625" : "CV",
            "346" : "KY",
            "623" : "CF",
            "622" : "TD",
            "730" : "CL",
            "460" : "CN",
            "732" : "CO",
            "654" : "KM",
            "629" : "CG",
            "548" : "CK",
            "712" : "CR",
            "219" : "HR",
            "368" : "CU",
            "280" : "CY",
            "230" : "CZ",
            "238" : "DK",
            "638" : "DJ",
            "366" : "DM",
            "370" : "DO",
            "740" : "EC",
            "602" : "EG",
            "706" : "SV",
            "627" : "GQ",
            "657" : "ER",
            "248" : "EE",
            "636" : "ET",
            "288" : "FO",
            "542" : "FJ",
            "244" : "FI",
            "208" : "FR",
            "340" : "GF",
            "547" : "PF",
            "628" : "GA",
            "607" : "GM",
            "282" : "GE",
            "262" : "DE",
            "620" : "GH",
            "266" : "GI",
            "202" : "GR",
            "290" : "GL",
            "352" : "GD",
            "704" : "GT",
            "611" : "GN",
            "632" : "GW",
            "738" : "GY",
            "372" : "HT",
            "708" : "HN",
            "216" : "HU",
            "274" : "IS",
            "404" : "IN",
            "405" : "IN",
            "510" : "ID",
            "418" : "IQ",
            "272" : "IE",
            "425" : "IL",
            "222" : "IT",
            "338" : "JM",
            "440" : "JP",
            "441" : "JP",
            "416" : "JO",
            "401" : "KZ",
            "439" : "KE",
            "545" : "KI",
            "419" : "KW",
            "437" : "KG",
            "247" : "LV",
            "415" : "LB",
            "651" : "LS",
            "618" : "LR",
            "295" : "LI",
            "246" : "LT",
            "270" : "LU",
            "646" : "MG",
            "650" : "MW",
            "502" : "MY",
            "472" : "MV",
            "610" : "ML",
            "278" : "MT",
            "551" : "MH",
            "609" : "MR",
            "617" : "MU",
            "334" : "MX",
            "212" : "MC",
            "428" : "MN",
            "297" : "ME",
            "354" : "MS",
            "604" : "MA",
            "414" : "MM",
            "649" : "NA",
            "536" : "NR",
            "429" : "NP",
            "204" : "NL",
            "362" : "SX",
            "599" : "AN",
            "546" : "NC",
            "530" : "NZ",
            "710" : "NI",
            "614" : "NE",
            "621" : "NG",
            "555" : "NU",
            "242" : "NO",
            "422" : "OM",
            "410" : "PK",
            "552" : "PW",
            "714" : "PA",
            "537" : "PG",
            "744" : "PY",
            "716" : "PE",
            "515" : "PH",
            "260" : "PL",
            "268" : "PT",
            "330" : "PR",
            "427" : "QA",
            "226" : "RO",
            "635" : "RW",
            "549" : "WS",
            "292" : "SM",
            "420" : "SA",
            "608" : "SN",
            "220" : "RS",
            "633" : "SC",
            "619" : "SL",
            "525" : "SG",
            "231" : "SK",
            "293" : "SI",
            "540" : "SB",
            "655" : "ZA",
            "659" : "SS",
            "500" : "GS",
            "214" : "ES",
            "413" : "LK",
            "634" : "SD",
            "746" : "SR",
            "653" : "SZ",
            "240" : "SE",
            "228" : "CH",
            "436" : "TJ",
            "520" : "TH",
            "615" : "TG",
            "554" : "TK",
            "539" : "TO",
            "374" : "TT",
            "605" : "TN",
            "286" : "TR",
            "438" : "TM",
            "376" : "TC",
            "553" : "TV",
            "641" : "UG",
            "255" : "UA",
            "424" : "AE",
            "234" : "GB",
            "235" : "GB",
            "310" : "US",
            "311" : "US",
            "312" : "US",
            "313" : "US",
            "314" : "US",
            "316" : "US",
            "748" : "UY",
            "434" : "UZ",
            "541" : "VU",
            "543" : "WF",
            "421" : "YE",
            "645" : "ZM",
            "648" : "ZW",
            "736" : "BO",
            "528" : "BN",
            "630" : "CD",
            "612" : "CI",
            "750" : "FK",
            "225" : "VA",
            "454" : "HK",
            "432" : "IR",
            "467" : "KP",
            "450" : "KR",
            "221" : "XK",
            "457" : "LA",
            "606" : "LY",
            "455" : "MO",
            "294" : "MK",
            "550" : "FM",
            "643" : "MZ",
            "647" : "RE",
            "250" : "RU",
            "658" : "SH",
            "356" : "KN",
            "308" : "PM",
            "360" : "VC",
            "626" : "ST",
            "637" : "SO",
            "417" : "SY",
            "466" : "TW",
            "640" : "TZ",
            "514" : "TL",
            "734" : "VE",
            "452" : "VN",
            "348" : "VG",
            "901" : "WD"
        ]
    
        var valueToReturn = "--"
        if dictCodes[country] != nil {
            valueToReturn = dictCodes[country] ?? "--"
        }
        
        if country == "425" && mnc == "05" {
            valueToReturn = "PS"
        }
        if country == "425" && mnc == "06" {
            valueToReturn = "PS"
        }
        if country == "234" && mnc == "55" {
            valueToReturn = "GG"
        }
        if country == "234" && mnc == "50" {
            valueToReturn = "GG"
        }
        if country == "234" && mnc == "03" {
            valueToReturn = "GG"
        }
        
        if country == "234" && mnc == "18" {
            valueToReturn = "IM"
        }
        if country == "234" && mnc == "36" {
            valueToReturn = "IM"
        }
        if country == "234" && mnc == "58" {
            valueToReturn = "IM"
        }
        
        if country == "234" && mnc == "28" {
            valueToReturn = "JE"
        }
        
        if (country == "340") && (mnc == "01" || mnc == "11") {
            valueToReturn = "GF"
        }
        if (country == "340") && (country == "02" || mnc == "09" || mnc == "10") {
            valueToReturn = "GP"
        }
        if country == "340" && mnc == "03" {
            valueToReturn = "BL"
        }
        if country == "340" && mnc == "08" {
            valueToReturn = "MF"
        }
        if country == "340" && mnc == "12" {
            valueToReturn = "MQ"
        }
        if country == "340" && mnc == "20" {
            valueToReturn = "MQ"
        }
        
        if country == "310" && (mnc == "110" || mnc == "11") {
            valueToReturn = "MP"
        }
        if country == "310" && (mnc == "370" || mnc == "37") {
            valueToReturn = "MP"
        }
        
        return valueToReturn
    }

}
