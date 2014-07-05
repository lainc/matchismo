//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Martin Mandl on 02.11.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "CardGameViewController.h"
#import "Deck.h"
#import "PlayingCardDeck.h"
#import "CardMatchingGame.h"

@interface CardGameViewController ()

@property (nonatomic, strong) CardMatchingGame *game;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSelector;
@property (strong, nonatomic)NSMutableArray *chosenCards;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation CardGameViewController

- (CardMatchingGame *)game
{
    if (!_game) {
        _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                  usingDeck:[self createDeck]];
        [self changeModeSelector:self.modeSelector];
    }
    return _game;
}

- (Deck *)createDeck
{
    return [[PlayingCardDeck alloc] init];
}
    
- (IBAction)touchDealButton:(UIButton *)sender
{
    self.modeSelector.enabled = YES;
    self.game = nil;
    [self.statusLabel setText:@""];
    [self updateUI];
}

- (IBAction)changeModeSelector:(UISegmentedControl *)sender
{
    self.game.maxMatchingCards = [[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] integerValue];
}

- (IBAction)touchCardButton:(UIButton *)sender
{
    self.modeSelector.enabled = NO;
    int cardIndex = [self.cardButtons indexOfObject:sender];
    [self.game chooseCardAtIndex:cardIndex];
    [self updateStatusLabel:cardIndex];
    [self updateUI];
}

- (void)updateUI
{
    for (UIButton *cardButton in self.cardButtons) {
        int cardIndex = [self.cardButtons indexOfObject:cardButton];
        Card *card = [self.game cardAtIndex:cardIndex];
        [cardButton setTitle:[self titleForCard:card]
                    forState:UIControlStateNormal];
        [cardButton setBackgroundImage:[self backgroundImageForCard:card]
                              forState:UIControlStateNormal];
        cardButton.enabled = !card.matched;
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
}

- (void)updateStatusLabel:(int)cardIndex
{
    Card *card = [self.game cardAtIndex:cardIndex];
    NSString *statusText;
    
    if (!card.isChosen) {
        statusText = @"";
        [self.chosenCards removeObject:card];
    } else if (card.isMatched) {
        statusText = [NSString stringWithFormat:@"Matched %@%@ for %d points.",
                      [self.chosenCards componentsJoinedByString:@""],
                      card,
                      4 * [card match:self.chosenCards]];
        [self.chosenCards removeAllObjects];
    } else {
        Card *firstCard = [self.chosenCards firstObject];
        if (!firstCard || firstCard.isChosen) {
            statusText = [card description];
            [self.chosenCards addObject:card];
        } else {
            statusText = [NSString stringWithFormat:@"%@%@ don't match! Lose 2 points!",
                          [self.chosenCards componentsJoinedByString:@""],
                          card];
            [self.chosenCards removeAllObjects];
            [self.chosenCards addObject:card];
        }
    }
        
    [self.statusLabel setText:statusText];
}

- (NSMutableArray *)chosenCards
{
    if (!_chosenCards) _chosenCards = [[NSMutableArray alloc] initWithCapacity:self.game.maxMatchingCards];
    return _chosenCards;
}

- (NSString *)titleForCard:(Card *)card
{
    return card.chosen ? card.contents : @"";
}

- (UIImage *)backgroundImageForCard:(Card *)card
{
    return [UIImage imageNamed:card.chosen ? @"cardfront" : @"cardback"];
}

@end
