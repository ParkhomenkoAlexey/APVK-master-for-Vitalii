//
//  String + Helpers.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 24/01/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

extension String {
    
    func height(fittingWidth width: CGFloat, font: UIFont) -> CGFloat {
        let fittingSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        
        
        // .boundingRect - Вычисляет и возвращает ограничивающий прямоугольник для получателя, нарисованного с использованием заданных параметров и характеристик отображения в пределах указанного прямоугольника в текущем графическом контексте.
        
        // .usesLineFragmentOrigin - Указанный источник - это источник фрагмента строки, а не источник базовой линии.
        let size = self.boundingRect(with: fittingSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
        return ceil(size.height)
    }
    
}
