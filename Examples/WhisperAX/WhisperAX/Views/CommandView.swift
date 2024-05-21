//
//  CommandView.swift
//  WhisperAX
//
//  Created by Andy.Chan on 2024/5/15.
//

import SwiftUI

struct CommandView: View {
    var body: some View {
        VStack(alignment: .leading, content: {
            Text("命令识别:")
                .bold()
                .frame(height: 40)
                .multilineTextAlignment(.leading)
                .padding(.leading, 20)
            Rectangle()
                .fill(.white)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            Spacer()
        })
    }
}

#Preview {
    CommandView()
}
