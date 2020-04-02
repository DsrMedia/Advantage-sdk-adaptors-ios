//
//  ADTeadsHandler.m
//  Affmaria
//
//  Created by Renato Neves Ribeiro on 03.03.20.
//  Copyright © 2020 Renato Neves Ribeiro. All rights reserved.
//

#import <AdvantageFramework/AdvantageFramework.h>
#import <TeadsSDK/TeadsSDK.h>
#import "AdvantageTeadsAdaptor.h"

NSString *const k_PID = @"pid";
NSString *const k_HAS_CMP = @"hasCMP";
NSString *const k_PAGE_URL = @"pageUrl";
NSString *const k_TEADS_INTEGRATION = @"https://support.teads.tv/support/solutions/articles/36000165919-2a-standard-integration";
NSString *const k_TEADS_PRIVACY = @"https://support.teads.tv/support/solutions/articles/36000166727-3-privacy-consent-management-gdpr-ccpa-";
//NSString *const k_TEADS_VALIDATION = @"https://support.teads.tv/support/solutions/articles/36000209100-5-validate-your-integration";

NSString *const k_US_PRIVACY = @"usPrivacyStringCCPA";
NSString *const k_CCPA_URL = @"https://www.cookiepro.com/knowledge/us-privacy-string/";

NSString *const k_SUBJECT_GDPR = @"subjectToGDPR";
NSString *const k_CONSENT_GDPR = @"consentGDPR";
NSString *const k_GDPR_URL = @"https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Mobile In-App Consent APIs v1.0 Final.md";


@interface ADvantageTeadsAdaptor () <TFAAdDelegate>

@property (nonatomic, nullable) ADvantage *adBanner;

@end

@implementation ADvantageTeadsAdaptor

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestAd:) name:@"teadsdkfallback" object:nil];
        self.debugEnabled = NO;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _adBanner = nil;
}

-(void)requestAd:(NSNotification *)notification {
    if ([[notification object] isKindOfClass:[ADvantage class]]) {
        self.adBanner = [notification object];
        for (UIView *subView in [self.adBanner.view subviews]) {
            [subView removeFromSuperview];
        }
        [self requestTeadsBanner];
    }
}

// MARK: - Teads

-(void)requestTeadsBanner {
    [self checkFallbackDictionary];
    if (self.adBanner.view.superview) {
        int pid = [[self.adBanner.fallBackAttributes objectForKey:k_PID] intValue];
        BOOL hasCMP = [[self.adBanner.fallBackAttributes objectForKey:k_HAS_CMP] boolValue];
        NSString *pageUrl = [[self.adBanner.fallBackAttributes objectForKey:k_PAGE_URL] stringValue];
        TFAInReadAdView *teadsBanner = [[TFAInReadAdView alloc] initWithPid:pid andDelegate:self];
        teadsBanner.frame = self.adBanner.view.frame;
        
        [self.adBanner.view.superview addSubview:teadsBanner];
        [self.adBanner.view removeFromSuperview];
        self.adBanner.view = teadsBanner;
        
        TeadsAdSettings *adSettings = [[TeadsAdSettings alloc] initWithBuild:^(TeadsAdSettings * setting) {
            [setting disableLocation];
//            [setting disableTeadsAudioSessionManagement];
            if (self.debugEnabled) {
                [setting enableValidationMode];
            }
            [setting pageUrl:pageUrl];
            if (!hasCMP) {
                if ([self.adBanner.fallBackAttributes objectForKey:k_US_PRIVACY]) {
                    [setting setUsPrivacyWithConsent:[[self.adBanner.fallBackAttributes objectForKey:k_US_PRIVACY] stringValue]]; // e.g. 1YNN
                }
                if ([self.adBanner.fallBackAttributes objectForKey:k_SUBJECT_GDPR] && [self.adBanner.fallBackAttributes objectForKey:k_CONSENT_GDPR]) {
                    [setting userConsentWithSubjectToGDPR:[[self.adBanner.fallBackAttributes objectForKey:k_SUBJECT_GDPR] stringValue] consent:[[self.adBanner.fallBackAttributes objectForKey:k_CONSENT_GDPR] stringValue]]; // The user consent following the IAB specifications :https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Mobile%20In-App%20Consent%20APIs%20v1.0%20Final.md
                }

            }
        }];
        
        [teadsBanner loadWithTeadsAdSettings:adSettings];
    } else {
        self.adBanner = nil;
    }
}

-(void)printDebug:(NSString *)printMessage {
    if (_debugEnabled) {
        NSLog(@"%@", printMessage);
    }
}

-(void)checkFallbackDictionary {

    NSAssert(([self.adBanner.fallBackAttributes objectForKey:k_PID] != nil), @"To use TeadSDK as an fallback, we need the key \"%@\" in the fallbackAttributes dictionary %@", k_PID, k_TEADS_INTEGRATION);
    NSAssert(([[self.adBanner.fallBackAttributes objectForKey:k_PID] isKindOfClass:[NSNumber class]]), @"\"%@\" value needs to be a NSNumber", k_PID);
    
    NSAssert(([self.adBanner.fallBackAttributes objectForKey:k_PAGE_URL] != nil), @"To use TeadSDK as an fallback, we need the key \"%@\" in the fallbackAttributes dictionary", k_PAGE_URL);
    NSAssert(([[self.adBanner.fallBackAttributes objectForKey:k_PAGE_URL] isKindOfClass:[NSString class]]), @"\"%@\" value needs to be a NSString", k_PAGE_URL);
    
    NSAssert(([self.adBanner.fallBackAttributes objectForKey:k_HAS_CMP] != nil), @"To use TeadSDK as an fallback, we need the key \"%@\" in the fallbackAttributes dictionary %@", k_HAS_CMP, k_TEADS_PRIVACY);
    NSAssert(([[self.adBanner.fallBackAttributes objectForKey:k_HAS_CMP] isKindOfClass:[NSNumber class]]), @"\"%@\" value needs to be a NSNumber", k_HAS_CMP);
        
        if (![[self.adBanner.fallBackAttributes objectForKey:k_HAS_CMP] boolValue]) {
    //        https://www.cookiepro.com/knowledge/us-privacy-string/
            NSLog(@"Check this url for more information about Teads privacy content %@", k_TEADS_PRIVACY);
//            NSAssert(([self.adBanner.fallBackAttributes objectForKey:k_US_PRIVACY] != nil), @"To use TeadSDK as an fallback, we need the key \"%@\" in the fallbackAttributes dictionary - %@", k_US_PRIVACY, k_CCPA_URL);
//            NSAssert(([[self.adBanner.fallBackAttributes objectForKey:k_US_PRIVACY] isKindOfClass:[NSString class]]), @"\"%@\" value needs to be a NSString", k_US_PRIVACY);
//
//            NSAssert(([self.adBanner.fallBackAttributes objectForKey:k_SUBJECT_GDPR] != nil), @"To use TeadSDK as an fallback, we need the key \"%@\" in the fallbackAttributes dictionary - %@", k_SUBJECT_GDPR, k_GDPR_URL);
//            NSAssert(([[self.adBanner.fallBackAttributes objectForKey:k_SUBJECT_GDPR] isKindOfClass:[NSString class]]), @"\"subjectToGDPR\" value needs to be a NSString");
//
//            NSAssert(([self.adBanner.fallBackAttributes objectForKey:k_CONSENT_GDPR] != nil), @"To use TeadSDK as an fallback, we need the key \"%@\" in the fallbackAttributes dictionary - %@", k_CONSENT_GDPR, k_GDPR_URL);
//            NSAssert(([[self.adBanner.fallBackAttributes objectForKey:k_CONSENT_GDPR] isKindOfClass:[NSString class]]), @"\"consentGDPR\" value needs to be a NSString");
        }
}

// MARK: - Teads Delegate

- (void)adClose:(TFAAdView * _Nonnull)ad userAction:(BOOL)userAction {
    
    [self printDebug:[NSString stringWithFormat:@"%s\n%@", __func__, ad]];
    if ([self.adBanner.delegate respondsToSelector:@selector(advantageDidClose:)]) {
        [self.adBanner.delegate advantageDidClose:self.adBanner];
    }
}

- (void)adError:(TFAAdView * _Nonnull)ad errorMessage:(NSString * _Nonnull)errorMessage {
    [self printDebug:[NSString stringWithFormat:@"%s\n%@", __func__, errorMessage]];
    if ([self.adBanner.delegate respondsToSelector:@selector(advantage:didFailWithError:)]) {
        [self.adBanner.delegate advantage:self.adBanner didFailWithError:errorMessage];
    }
}

- (void)didFailToReceiveAd:(TFAAdView * _Nonnull)ad adFailReason:(AdFailReason * _Nonnull)adFailReason {
    [self printDebug:[NSString stringWithFormat:@"%s\n%@", __func__, [adFailReason errorMessage]]];
    if ([self.adBanner.delegate respondsToSelector:@selector(advantage:didFailWithError:)]) {
        [self.adBanner.delegate advantage:self.adBanner didFailWithError:[adFailReason errorMessage]];
    }
}

- (void)didReceiveAd:(TFAAdView * _Nonnull)ad adRatio:(CGFloat)adRatio {
    [self printDebug:[NSString stringWithFormat:@"%s\n%f - %@", __func__, adRatio, ad]];
    if ([self.adBanner.delegate respondsToSelector:@selector(advantage:didUpdateBannerHeightTo:)]) {
        [self.adBanner.delegate advantage:self.adBanner didUpdateBannerHeightTo:(self.adBanner.view.frame.size.width * adRatio)];
    }
}

@end
