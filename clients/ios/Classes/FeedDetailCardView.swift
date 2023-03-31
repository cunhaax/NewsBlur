//
//  FeedDetailCardView.swift
//  NewsBlur
//
//  Created by David Sinclair on 2023-02-01.
//  Copyright © 2023 NewsBlur. All rights reserved.
//

import SwiftUI
import SwipeCell

/// Card view within the feed detail view, representing a story row in list layout or a story card in grid layout.
struct CardView: View {
    let cache: StoryCache
    
    let story: Story
    
//        @Binding var swipeState: SwipeState
//    @Binding var currentUserInteractionCellID: String?
    
    @State private var isPinned: Bool = false
    
    var body: some View {
        let swipeSaveButton = SwipeCellButton(
            buttonStyle: .view,
            title: "",
            systemImage: "",
            titleColor: .white,
            imageColor: .white,
            view: {
//                AnyView(
//                    Circle()
//                        .fill(Color.blue)
//                        .frame(width: 40, height: 40)
//                        .overlay(
//                            Image(uiImage: UIImage(named: "saved-stories") ?? UIImage())
//                                .resizable()
//                                .frame(width: 32, height: 32)
//                                .font(.headline)
//                                .foregroundColor(.white)
//                        )
//                )
//                AnyView(
//                    Image(uiImage: UIImage(named: "saved-stories") ?? UIImage())
//                        .resizable()
//                        .frame(width: 32, height: 32)
//                        .font(.headline)
//                        .foregroundColor(.white)
//                )
                AnyView(
                    VStack(spacing: 5) {
                        Image(uiImage: UIImage(named: "saved-stories") ?? UIImage())
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.white)
                        Text(story.isSaved ? "Unsave" : "Save")
                            .font(.callout)
                            .bold()
                            .foregroundColor(.white)
                    }
                )},
            backgroundColor: .purple,
            action: {
                cache.appDelegate.storiesCollection.toggleStorySaved(story.dictionary)
                cache.appDelegate.feedDetailViewController.reload()
            },
            feedback: true
        )
        
        let swipeReadButton = SwipeCellButton(
            buttonStyle: .view,
            title: "",
            systemImage: "",
            titleColor: .white,
            imageColor: .white,
            view: {
                AnyView(
                    VStack(spacing: 5) {
                        Image(uiImage: UIImage(named: "mark-read") ?? UIImage())
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.white)
                        Text(story.isRead ? "Unread" : "Read")
                            .font(.callout)
                            .bold()
                            .foregroundColor(.white)
                    }
                )},
//                AnyView(
//                    Image(uiImage: UIImage(named: "mark-read") ?? UIImage())
//                        .resizable()
//                        .frame(width: 32, height: 32)
//                        .font(.headline)
//                        .foregroundColor(.white)
//                )
//            },
            backgroundColor: .blue,
            action: {
                cache.appDelegate.storiesCollection.toggleStoryUnread(story.dictionary)
                cache.appDelegate.feedDetailViewController.reload()
            },
            feedback: true
        )
        
        ZStack(alignment: .leading) {
            if story.isSelected || cache.isGrid {
                RoundedRectangle(cornerRadius: 10).foregroundColor(highlightColor)
                
                CardFeedBarView(cache: cache, story: story)
                    .padding(.leading, 2)
            } else {
                CardFeedBarView(cache: cache, story: story)
                    .padding(.leading, 2)
            }
            
            VStack {
                if cache.isGrid, let previewImage {
                    gridPreview(image: previewImage)
//                    Image(uiImage: previewImage)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(height: cache.settings.gridHeight / 3)
//                        .cornerRadius(12, corners: [.topLeft, .topRight])
//                        .padding(0)
                }
                
                HStack {
                    if !cache.isGrid, cache.settings.preview.isLeft, let previewImage {
                        listPreview(image: previewImage)
                    }
                    
                    CardContentView(cache: cache, story: story)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], 15)
                        .padding([.top, .bottom], cache.settings.spacing == .compact ? 10 : 15)
                    
                    if !cache.isGrid, !cache.settings.preview.isLeft, let previewImage {
                        listPreview(image: previewImage)
                        
//                        Image(uiImage: previewImage)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 80)
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                            .padding([.top, .bottom, .trailing], 10)
                    }
                }
            }
        }
        .opacity(story.isRead ? 0.7 : 1)
        .if(cache.isGrid || story.isSelected) { view in
            view.clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .if(story.isSelected) { view in
            view.padding(10)
        }
//        .addFullSwipeAction(swipeColor: .clear, swipeRole: .defaults, state: $swipeState) {
//            Leading {
//                Button {
//                    print("edit \(story)")
//                } label: {
//                    Image(systemName: "pencil")
//                        .foregroundColor(.white)
//                }
//                .frame(width: 80, alignment: .center)
//                .frame(maxHeight: .infinity)
//                .contentShape(Rectangle())
//                .background(Color.green)
//            }
//            Trailing {
//                Button {
//                    print("remove \(story)")
//                } label: {
//                    Image(systemName: "trash")
//                        .foregroundColor(.white)
//                }
//                .frame(width: 80, alignment: .center)
//                .frame(maxHeight: .infinity)
//                .contentShape(Rectangle())
//                .background(Color.blue)
//            }
//        }
//        .swipeCell(id: story.id.uuidString, cellWidth: 60, leadingSideGroup: leftGroup(), trailingSideGroup: rightGroup(), currentUserInteractionCellID: $currentUserInteractionCellID, settings: SwipeCellSettings())
//        .onSwipe(leading: slots, trailing: slots)
        .swipeCell(cellPosition: .both, leftSlot: SwipeCellSlot(slots: [swipeSaveButton], slotStyle: .destructive, buttonWidth: 80), rightSlot: SwipeCellSlot(slots: [swipeReadButton], slotStyle: .destructive, buttonWidth: 80))
        .dismissSwipeCellForScrollViewForLazyVStack()
        .contextMenu {
            Button {
                cache.appDelegate.storiesCollection.toggleStoryUnread(story.dictionary)
                cache.appDelegate.feedDetailViewController.reload()
            } label: {
                Label(story.isRead ? "Mark as unread" : "Mark as read", image: "mark-read")
            }
            
            Button {
                cache.appDelegate.feedDetailViewController.markFeedsRead(fromTimestamp: story.timestamp, andOlder: false)
                cache.appDelegate.feedDetailViewController.reload()
            } label: {
                Label("Mark newer stories read", image: "mark-read")
            }
            
            Button {
                cache.appDelegate.feedDetailViewController.markFeedsRead(fromTimestamp: story.timestamp, andOlder: true)
                cache.appDelegate.feedDetailViewController.reload()
            } label: {
                Label("Mark older stories read", image: "mark-read")
            }
            
            Button {
                cache.appDelegate.storiesCollection.toggleStorySaved(story.dictionary)
                cache.appDelegate.feedDetailViewController.reload()
            } label: {
                Label(story.isSaved ? "Unsave this story" : "Save this story", image: "saved-stories")
            }
            
            Button {
                cache.appDelegate.showSend(to: cache.appDelegate.feedDetailViewController, sender: cache.appDelegate.feedDetailViewController.view)
            } label: {
                Label("Send this story to…", image: "email")
            }
            
            Button {
                cache.appDelegate.openTrainStory(nil)
            } label: {
                Label("Train this story", image: "train")
            }
        }
    }
    
    //    var body: some View {
    //        if cache.isGrid {
    //            ZStack(alignment: .leading) {
    //                RoundedRectangle(cornerRadius: 12).foregroundColor(.init(white: 0.9))
    //
    //                CardFeedBarView(cache: cache, story: story)
    //                    .clipShape(RoundedRectangle(cornerRadius: 12))
    //                    .padding(.leading, 1)
    //
    //                VStack {
    //                    //                RoundedRectangle(cornerRadius: 12).foregroundColor(.random)
    //                    //                    .frame(height: 200)
    //
    //                    if let previewImage {
    //                        Image(uiImage: previewImage)
    //                            .resizable()
    //                            .scaledToFill()
    //                            .frame(height: 200)
    //                        //                            .clipped()
    //                        //                            .clipShape(RoundedRectangle(cornerRadius: 12))
    //                            .cornerRadius(12, corners: [.topLeft, .topRight])
    //                            .padding(0)
    //                    }
    //
    //                    CardContentView(cache: cache, story: story)
    //                        .frame(maxHeight: .infinity, alignment: .leading)
    //                        .padding(10)
    //                }
    //            }
    //        } else {
    //            ZStack(alignment: .leading) {
    //                if story.isSelected {
    //                    RoundedRectangle(cornerRadius: 12).foregroundColor(.init(white: 0.9))
    //                    //                        .padding(10)
    //
    //                    CardFeedBarView(cache: cache, story: story)
    //                        .clipShape(RoundedRectangle(cornerRadius: 12))
    //                    //                        .padding(10)
    //                } else {
    //                    CardFeedBarView(cache: cache, story: story)
    //                        .padding(.leading, 2)
    //                }
    //
    //                HStack {
    //                    CardContentView(cache: cache, story: story)
    //                        .frame(maxWidth: .infinity, alignment: .leading)
    //                        .padding([.top, .bottom], 10)
    //                        .padding(.leading, 15)
    //
    //                    if let previewImage {
    //                        Image(uiImage: previewImage)
    //                            .resizable()
    //                            .scaledToFill()
    //                            .frame(width: 80)
    //                            .clipShape(RoundedRectangle(cornerRadius: 10))
    //                            .padding([.top, .bottom, .trailing], 10)
    //                    }
    //                }
    //            }
    //            .if(story.isSelected) { view in
    //                view.padding(10)
    //            }
    //        }
    //    }
    
    var highlightColor: Color {
        if cache.isGrid {
            return Color.themed([0xFDFCFA, 0xFFFDEF, 0x4F4F4F, 0x292B2C])
        } else {
            return Color.themed([0xFFFDEF, 0xEEECCD, 0x303A40, 0x303030])
        }
    }
    
    var previewImage: UIImage? {
        guard cache.settings.preview != .none, let image = cache.appDelegate.cachedImage(forStoryHash: story.hash), image.isKind(of: UIImage.self) else {
            return nil
        }
        
        return image
    }
    
    @ViewBuilder
    func gridPreview(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: cache.settings.gridHeight / 3)
            .cornerRadius(10, corners: .topRight)
            .padding(0)
            .padding(.leading, 8)
    }
    
    @ViewBuilder
    func listPreview(image: UIImage) -> some View {
        let isLeft = cache.settings.preview.isLeft
        
        if cache.settings.preview.isSmall {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding([.top, .bottom], 10)
                .padding(.leading, isLeft ? 15 : -10)
                .padding(.trailing, isLeft ? -10 : 10)
        } else {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 90)
                .clipped()
                .padding(.leading, isLeft ? 8 : -10)
                .padding(.trailing, isLeft ? -10 : 0)
        }
        
        //        if cache.settings.listPreview.isLeft {
        //            return image.padding(.trailing, 10)
        //        } else {
        //            return image.padding(.leading, 10)
        //        }
        //        //these cause it to crash; too complex? could try assigning the above to variable then add these
        //            .if(cache.settings.listPreview.isLeft) { view in
        //                self.padding(.trailing, 10)
        //            }
        //            .if(!cache.settings.listPreview.isLeft) { view in
        //                self.padding(.leading, 10)
        //            }
    }
    
    
    //    func leftGroup()->[SwipeCellActionItem] {
    //        return [SwipeCellActionItem(buttonView: {
    //
    //            VStack(spacing: 2)  {
    //                Image(systemName: "person.crop.circle.badge.plus").font(.system(size: 22)).foregroundColor(.white)
    //                Text("Share").fixedSize().font(.system(size: 12)).foregroundColor(.white)
    //            }.frame(maxHeight: 80).castToAnyView()
    //
    //        }, backgroundColor: .blue)
    //                {
    //            print("share action!")
    //        }]
    
    //        return [ SwipeCellActionItem(buttonView: {
    //
    //            self.pinView(swipeOut: false)
    //
    //        }, swipeOutButtonView: {
    //            self.pinView(swipeOut: true)
    //        }, buttonWidth: 80, backgroundColor: .yellow, swipeOutAction: true, swipeOutHapticFeedbackType: .success, swipeOutIsDestructive: false)
    //                 {
    //            print("pin action!")
    //            self.isPinned.toggle()
    //        }]
    //    }
    //
    //    func pinView(swipeOut: Bool)->AnyView {
    //
    //        Group {
    //            Spacer()
    //            VStack(spacing: 2) {
    //                Image(systemName: self.isPinned ? "pin.slash": "pin").font(.system(size: 24)).foregroundColor(.white)
    //                Text(self.isPinned ? "Unpin": "Pin").fixedSize().font(.system(size: 14)).foregroundColor(.white)
    //            }.frame(maxHeight: 80).padding(.horizontal, swipeOut ? 20 : 5)
    //            if swipeOut == false {
    //                Spacer()
    //            }
    //        }.animation(.default).castToAnyView()
    //
    //    }
    //
    //
    //    func rightGroup()->[SwipeCellActionItem] {
    //
    //        let items =  [
    //            SwipeCellActionItem(buttonView: {
    //
    //                VStack(spacing: 2)  {
    //                    Image(systemName: "person.crop.circle.badge.plus").font(.system(size: 22)).foregroundColor(.white)
    //                    Text("Share").fixedSize().font(.system(size: 12)).foregroundColor(.white)
    //                }.frame(maxHeight: 80).castToAnyView()
    //
    //            }, backgroundColor: .blue)
    //            {
    //                print("share action!")
    //            },
    //            SwipeCellActionItem(buttonView: {
    //                VStack(spacing: 2)  {
    //                    Image(systemName: "folder.fill").font(.system(size: 22)).foregroundColor(.white)
    //                    Text("Move").fixedSize().font(.system(size: 12)).foregroundColor(.white)
    //                }.frame(maxHeight: 80).castToAnyView()
    //
    //            }, backgroundColor: .purple, actionCallback: {
    //                print("folder action")
    //            }),
    //
    //            SwipeCellActionItem(buttonView: {
    //                self.trashView(swipeOut: false)
    //            }, swipeOutButtonView: {
    //                self.trashView(swipeOut: true)
    //            }, backgroundColor: .red, swipeOutAction: true, swipeOutHapticFeedbackType: .warning, swipeOutIsDestructive: true) {
    //                print("delete action")
    ////                self.deletionCallback(item)
    //            }
    //        ]
    //
    //        return items
    //    }
    //
    //    func trashView(swipeOut: Bool)->AnyView {
    //        VStack(spacing: 3)  {
    //            Image(systemName: "trash").font(.system(size: swipeOut ? 28 : 22)).foregroundColor(.white)
    //            Text("Delete").fixedSize().font(.system(size: swipeOut ? 16 : 12)).foregroundColor(.white)
    //        }.frame(maxHeight: 80).animation(.default).castToAnyView()
    //
    //    }
    
    
//    var slots = [
//        // First item
//        Slot(
//            image: {
//                Image(systemName: "envelope.open.fill")
//            },
//            title: {
//                Text("Read")
//                    .foregroundColor(.white)
//                    .font(.footnote)
//                    .fontWeight(.semibold)
//                    .embedInAnyView()
//            },
//            action: { print("Read Slot tapped") },
//            style: .init(background: .orange)
//        ),
//        // Second item
//        Slot(
//            image: {
//                Image(systemName: "hand.raised.fill")
//            },
//            title: {
//                Text("Block")
//                    .foregroundColor(.white)
//                    .font(.footnote)
//                    .fontWeight(.semibold)
//                    .embedInAnyView()
//            },
//            action: { print("Block Slot Tapped") },
//            style: .init(background: .blue, imageColor: .red)
//        )
//    ]

//struct CardView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardView(cache: StoryCache(), story: Story(index: 0))
//    }
}

struct CardContentView: View {
    let cache: StoryCache
    
    let story: Story
    
    var body: some View {
        VStack(alignment: .leading) {
            if story.isRiverOrSocial, let feedImage {
                HStack {
                    Image(uiImage: feedImage)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(.leading, 24)
                    
                    Text(story.feedName)
                        .font(font(named: "WhitneySSm-Medium", size: 12))
                        .lineLimit(1)
                        .foregroundColor(feedColor)
                }
            }
            
            HStack(alignment: .top) {
                if let unreadImage {
                    Image(uiImage: unreadImage)
                        .resizable()
                        .opacity(story.isRead ? 0.15 : 1)
                        .frame(width: 16, height: 16)
                        .padding(.top, 3)
                }
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        if story.isSaved, let image = UIImage(named: "saved-stories") {
                            Image(uiImage: image)
                                .resizable()
                                .opacity(story.isRead ? 0.15 : 1)
                                .frame(width: 16, height: 16)
                                .padding(.top, 3)
                        }
                        
                        if story.isShared, let image = UIImage(named: "share") {
                            Image(uiImage: image)
                                .resizable()
                                .opacity(story.isRead ? 0.15 : 1)
                                .frame(width: 16, height: 16)
                                .padding(.top, 3)
                        }
                        
                        Text(story.title)
                            .font(font(named: "WhitneySSm-Medium", size: 18).bold())
                            .foregroundColor(titleColor)
                            .lineLimit(cache.isGrid ? StorySettings.Content.titleLimit : cache.settings.content.limit)
                            .truncationMode(.tail)
                    }
                    .padding(.bottom, cache.settings.spacing == .compact ? -5 : 0)
                    
                    if cache.isGrid || cache.settings.content != .title {
                        Text(story.content)
                            .font(font(named: "WhitneySSm-Book", size: 13))
                            .foregroundColor(contentColor)
                            .lineLimit(cache.isGrid ? StorySettings.Content.contentLimit : cache.settings.content.limit)
                            .truncationMode(.tail)
                            .padding(.top, 5)
                            .padding(.bottom, cache.settings.spacing == .compact ? -5 : 0)
                    }
                    
                    Spacer()
                    
                    Text(story.dateAndAuthor)
                        .font(font(named: "WhitneySSm-Medium", size: 12))
                        .foregroundColor(dateAndAuthorColor)
                        .padding(.top, 5)
                }
            }
        }
    }
    
    var feedImage: UIImage? {
        if let image = cache.appDelegate.getFavicon(story.feedID) {
            return Utilities.roundCorneredImage(image, radius: 4, convertTo: CGSizeMake(16, 16))
        } else {
            return nil
        }
    }
    
    var unreadImage: UIImage? {
        guard story.isReadAvailable else {
            return nil
        }
        
        switch story.score {
        case -1:
            return UIImage(named: "indicator-hidden")
        case 1:
            return UIImage(named: "indicator-focus")
        default:
            return UIImage(named: "indicator-unread")
        }
    }
    
    func font(named: String, size: CGFloat) -> Font {
        return Font.custom(named, size: size + cache.settings.fontSize.offset, relativeTo: .caption)
    }
    
    var feedColor: Color {
        return contentColor
    }
    
    var titleColor: Color {
        if story.isSelected {
            return Color.themed([0x686868, 0xA0A0A0])
        } else if story.isRead {
            return Color.themed([0x585858, 0x585858, 0x989898, 0x888888])
        } else {
            return Color.themed([0x111111, 0x333333, 0xD0D0D0, 0xCCCCCC])
        }
    }
    
    var contentColor: Color {
        if story.isSelected, story.isRead {
            return Color.themed([0xB8B8B8, 0xB8B8B8, 0xA0A0A0, 0x707070])
        } else if story.isSelected {
            return Color.themed([0x888785, 0x686868, 0xA9A9A9, 0x989898])
        } else if story.isRead {
            return Color.themed([0xB8B8B8, 0xB8B8B8, 0xA0A0A0, 0x707070])
        } else {
            return Color.themed([0x404040, 0x404040, 0xC0C0C0, 0xB0B0B0])
        }
    }
    
    var dateAndAuthorColor: Color {
        return contentColor
    }
}

struct CardFeedBarView: View {
    let cache: StoryCache
    
    let story: Story
    
    var body: some View {
        GeometryReader { geometry in
            if let color = story.feedColorBarLeft {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                }
                .stroke(Color(color), lineWidth: 4)
            }
            
            if let color = story.feedColorBarRight {
                Path { path in
                    path.move(to: CGPoint(x: 4, y: 0))
                    path.addLine(to: CGPoint(x: 4, y: geometry.size.height))
                }
                .stroke(Color(color), lineWidth: 4)
            }
        }
        
        
//        if #available(iOS 15.0, *) {
//            Canvas { context, size in
//                context.stroke(
//                    Path(CGRect(origin: .zero, size: CGSize(width: 0, height: size.height))),
//                    with: .color(.green),
//                    lineWidth: 4)
//
//                context.stroke(
//                    Path(CGRect(origin: CGPoint(x: 5, y: 0), size: CGSize(width: 0, height: size.height))),
//                    with: .color(.blue),
//                    lineWidth: 4)
//            }
//            Canvas { context, size in
//                let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//
//                Path { path in
//                    path.move(to: CGPoint(x: 0, y: 0))
//                    path.addLine(to: CGPoint(x: 0, y: size.height))
//                }
//                .stroke(.blue, lineWidth: 10)
//
//                Path { path in
//                    path.move(to: CGPoint(x: 10, y: 0))
//                    path.addLine(to: CGPoint(x: 10, y: size.height))
//                }
//                .stroke(.green, lineWidth: 10)
//            }
//        } else {
//            EmptyView()
//        }
        
        
//        Path { path in
//            path.move(to: CGPoint(x: 0, y: 0))
//            path.addLine(to: CGPoint(x: 100, y: 300))
//            path.addLine(to: CGPoint(x: 300, y: 300))
//            path.addLine(to: CGPoint(x: 200, y: 100))
//            path.closeSubpath()
//        }
//        .stroke(.blue, lineWidth: 10)
        
        
        
        //    CGFloat feedBarOffset = isHighlighted ? 2 : 0;
        //    CGContextSetStrokeColor(context, CGColorGetComponents([self.feedColorBarTopBorder CGColor]));
        //    if (self.isRead) {
        //        CGContextSetAlpha(context, 0.15);
        //    }
        //    CGContextSetLineWidth(context, 4.0f);
        //    CGContextBeginPath(context);
        //    CGContextMoveToPoint(context, 2.0f + feedBarOffset, 0);
        //    CGContextAddLineToPoint(context, 2.0f + feedBarOffset, self.frame.size.height);
        //    CGContextStrokePath(context);
        //
        //    CGContextSetStrokeColor(context, CGColorGetComponents([self.feedColorBar CGColor]));
        //    CGContextBeginPath(context);
        //    CGContextMoveToPoint(context, 6.0f + feedBarOffset, 0);
        //    CGContextAddLineToPoint(context, 6.0 + feedBarOffset, self.frame.size.height);
        //    CGContextStrokePath(context);
        

    }
}

//extension ShapeStyle where Self == Color {
//    static var darkBackground: Color {
//        Color(red: 0.1, green: 0.1, blue: 0.2)
//    }
//    static var lightBackground: Color {
//        Color(red: 0.2, green: 0.2, blue: 0.3)
//    }
//}
