//
//  BranchConstants.h
//  Branch-TestBed
//
//  Created by Graham Mueller on 6/10/15.
//  Copyright (c) 2015 Branch Metrics. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const BRANCH_REQUEST_KEY_BRANCH_IDENTITY;
extern NSString * const BRANCH_REQUEST_KEY_DEVELOPER_IDENTITY;
extern NSString * const BRANCH_REQUEST_KEY_DEVICE_FINGERPRINT_ID;
extern NSString * const BRANCH_REQUEST_KEY_SESSION_ID;
extern NSString * const BRANCH_REQUEST_KEY_ACTION;
extern NSString * const BRANCH_REQUEST_KEY_STATE;
extern NSString * const BRANCH_REQUEST_KEY_BUCKET;
extern NSString * const BRANCH_REQUEST_KEY_AMOUNT;
extern NSString * const BRANCH_REQUEST_KEY_LENGTH;
extern NSString * const BRANCH_REQUEST_KEY_DIRECTION;
extern NSString * const BRANCH_REQUEST_KEY_STARTING_TRANSACTION_ID;
extern NSString * const BRANCH_REQUEST_KEY_REFERRAL_USAGE_TYPE;
extern NSString * const BRANCH_REQUEST_KEY_REFERRAL_REWARD_LOCATION;
extern NSString * const BRANCH_REQUEST_KEY_REFERRAL_TYPE;
extern NSString * const BRANCH_REQUEST_KEY_REFERRAL_CREATION_SOURCE;
extern NSString * const BRANCH_REQUEST_KEY_REFERRAL_PREFIX;
extern NSString * const BRANCH_REQUEST_KEY_REFERRAL_EXPIRATION;
extern NSString * const BRANCH_REQUEST_KEY_REFERRAL_CODE;
extern NSString * const BRANCH_REQUEST_KEY_URL_SOURCE;
extern NSString * const BRANCH_REQUEST_KEY_URL_TAGS;
extern NSString * const BRANCH_REQUEST_KEY_URL_LINK_TYPE;
extern NSString * const BRANCH_REQUEST_KEY_URL_ALIAS;
extern NSString * const BRANCH_REQUEST_KEY_URL_CHANNEL;
extern NSString * const BRANCH_REQUEST_KEY_URL_FEATURE;
extern NSString * const BRANCH_REQUEST_KEY_URL_STAGE;
extern NSString * const BRANCH_REQUEST_KEY_URL_DURATION;
extern NSString * const BRANCH_REQUEST_KEY_URL_DATA;
extern NSString * const BRANCH_REQUEST_KEY_URL_IGNORE_UA_STRING;
extern NSString * const BRANCH_REQUEST_KEY_APP_LIST;
extern NSString * const BRANCH_REQUEST_KEY_HARDWARE_ID;
extern NSString * const BRANCH_REQUEST_KEY_IS_HARDWARE_ID_REAL;
extern NSString * const BRANCH_REQUEST_KEY_AD_TRACKING_ENABLED;
extern NSString * const BRANCH_REQUEST_KEY_IS_REFERRABLE;
extern NSString * const BRANCH_REQUEST_KEY_DEBUG;
extern NSString * const BRANCH_REQUEST_KEY_BUNDLE_ID;
extern NSString * const BRANCH_REQUEST_KEY_TEAM_ID;
extern NSString * const BRANCH_REQUEST_KEY_APP_VERSION;
extern NSString * const BRANCH_REQUEST_KEY_OS;
extern NSString * const BRANCH_REQUEST_KEY_OS_VERSION;
extern NSString * const BRANCH_REQUEST_KEY_URI_SCHEME;
extern NSString * const BRANCH_REQUEST_KEY_UPDATE;
extern NSString * const BRANCH_REQUEST_KEY_LINK_IDENTIFIER;
extern NSString * const BRANCH_REQUEST_KEY_SPOTLIGHT_IDENTIFIER;
extern NSString * const BRANCH_REQUEST_KEY_UNIVERSAL_LINK_URL;
extern NSString * const BRANCH_REQUEST_KEY_BRAND;
extern NSString * const BRANCH_REQUEST_KEY_MODEL;
extern NSString * const BRANCH_REQUEST_KEY_SCREEN_WIDTH;
extern NSString * const BRANCH_REQUEST_KEY_SCREEN_HEIGHT;
extern NSString * const BRANCH_REQUEST_KEY_IS_SIMULATOR;
extern NSString * const BRANCH_REQUEST_KEY_LOG;
extern NSString * const BRANCH_REQUEST_KEY_EXTERNAL_INTENT_URI;

extern NSString * const BRANCH_REQUEST_ENDPOINT_SET_IDENTITY;
extern NSString * const BRANCH_REQUEST_ENDPOINT_LOGOUT;
extern NSString * const BRANCH_REQUEST_ENDPOINT_USER_COMPLETED_ACTION;
extern NSString * const BRANCH_REQUEST_ENDPOINT_LOAD_ACTIONS;
extern NSString * const BRANCH_REQUEST_ENDPOINT_LOAD_REWARDS;
extern NSString * const BRANCH_REQUEST_ENDPOINT_REDEEM_REWARDS;
extern NSString * const BRANCH_REQUEST_ENDPOINT_CREDIT_HISTORY;
extern NSString * const BRANCH_REQUEST_ENDPOINT_GET_PROMO_CODE;
extern NSString * const BRANCH_REQUEST_ENDPOINT_GET_REFERRAL_CODE;
extern NSString * const BRANCH_REQUEST_ENDPOINT_VALIDATE_PROMO_CODE;
extern NSString * const BRANCH_REQUEST_ENDPOINT_VALIDATE_REFERRAL_CODE;
extern NSString * const BRANCH_REQUEST_ENDPOINT_APPLY_PROMO_CODE;
extern NSString * const BRANCH_REQUEST_ENDPOINT_APPLY_REFERRAL_CODE;
extern NSString * const BRANCH_REQUEST_ENDPOINT_GET_SHORT_URL;
extern NSString * const BRANCH_REQUEST_ENDPOINT_CLOSE;
extern NSString * const BRANCH_REQUEST_ENDPOINT_GET_APP_LIST;
extern NSString * const BRANCH_REQUEST_ENDPOINT_UPDATE_APP_LIST;
extern NSString * const BRANCH_REQUEST_ENDPOINT_OPEN;
extern NSString * const BRANCH_REQUEST_ENDPOINT_INSTALL;
extern NSString * const BRANCH_REQUEST_ENDPOINT_CONNECT_DEBUG;
extern NSString * const BRANCH_REQUEST_ENDPOINT_DISCONNECT_DEBUG;
extern NSString * const BRANCH_REQUEST_ENDPOINT_LOG;
extern NSString * const BRANCH_REQUEST_ENDPOINT_REGISTER_VIEW;

extern NSString * const BRANCH_RESPONSE_KEY_BRANCH_IDENTITY;
extern NSString * const BRANCH_RESPONSE_KEY_SESSION_ID;
extern NSString * const BRANCH_RESPONSE_KEY_USER_URL;
extern NSString * const BRANCH_RESPONSE_KEY_INSTALL_PARAMS;
extern NSString * const BRANCH_RESPONSE_KEY_ACTION_COUNT_TOTAL;
extern NSString * const BRANCH_RESPONSE_KEY_ACTION_COUNT_UNIQUE;
extern NSString * const BRANCH_RESPONSE_KEY_REFERRER;
extern NSString * const BRANCH_RESPONSE_KEY_REFERREE;
extern NSString * const BRANCH_RESPONSE_KEY_REFERRAL_CODE;
extern NSString * const BRANCH_RESPONSE_KEY_PROMO_CODE;
extern NSString * const BRANCH_RESPONSE_KEY_URL;
extern NSString * const BRANCH_RESPONSE_KEY_SPOTLIGHT_IDENTIFIER;
extern NSString * const BRANCH_RESPONSE_KEY_POTENTIAL_APPS;
extern NSString * const BRANCH_RESPONSE_KEY_DEVELOPER_IDENTITY;
extern NSString * const BRANCH_RESPONSE_KEY_DEVICE_FINGERPRINT_ID;
extern NSString * const BRANCH_RESPONSE_KEY_SESSION_DATA;
extern NSString * const BRANCH_RESPONSE_KEY_CLICKED_BRANCH_LINK;
extern NSString * const BRANCH_RESPONSE_KEY_BRANCH_VIEW_DATA;

extern NSString * const BRANCH_LINK_DATA_KEY_OG_TITLE;
extern NSString * const BRANCH_LINK_DATA_KEY_OG_DESCRIPTION;
extern NSString * const BRANCH_LINK_DATA_KEY_OG_IMAGE_URL;
extern NSString * const BRANCH_LINK_DATA_KEY_TITLE;
extern NSString * const BRANCH_LINK_DATA_KEY_DESCRIPTION;
extern NSString * const BRANCH_LINK_DATA_KEY_PUBLICLY_INDEXABLE;
extern NSString * const BRANCH_LINK_DATA_KEY_TYPE;
extern NSString * const BRANCH_LINK_DATA_KEY_THUMBNAIL_URL;
extern NSString * const BRANCH_LINK_DATA_KEY_KEYWORDS;
extern NSString * const BRANCH_LINK_DATA_KEY_CANONICAL_IDENTIFIER;
extern NSString * const BRANCH_LINK_DATA_KEY_CANONICAL_URL;
extern NSString * const BRANCH_LINK_DATA_KEY_CONTENT_EXPIRATION_DATE;
extern NSString * const BRANCH_LINK_DATA_KEY_CONTENT_TYPE;
extern NSString * const BRANCH_LINK_DATA_KEY_EMAIL_SUBJECT;

extern NSString * const BRANCH_WALLET_PASS_MAIN_KEY;
extern NSString * const BRANCH_WALLET_PASS_KEY_SERIAL;
extern NSString * const BRANCH_WALLET_PASS_KEY_TYPE_IDENT;
extern NSString * const BRANCH_WALLET_PASS_KEY_USER_INFO;

extern NSString * const BRANCH_SPOTLIGHT_PREFIX;
