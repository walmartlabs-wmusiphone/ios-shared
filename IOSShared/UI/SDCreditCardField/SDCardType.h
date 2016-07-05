//
//  SDCardType.h
//  SetDirection
//
//  Created by Alex MacCaw on 01/22/2013.
//  Copyright (c) 2013 Stripe. All rights reserved.
//
//  Adapted by Steven Woolgar on 02/24/2014
//

#ifndef __SDCardType_h__
#define __SDCardType_h__

typedef NS_ENUM(NSUInteger, SDCardType)
{
    SDCardTypeVisa,
    SDCardTypeMasterCard,
    SDCardTypeAmex,
    SDCardTypeDiscover,
    SDCardTypeJCB,
    SDCardTypeDinersClub,
    SDCardTypeSamsClub,
    SDCardTypeSamsClubBusiness,
    SDCardTypeUnknown
};

#endif // __SDCardType_h__
