﻿using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;

namespace ESME.Views.Controls
{
    public class HiddenIfNull : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return value == null ? Visibility.Hidden : Visibility.Visible;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
