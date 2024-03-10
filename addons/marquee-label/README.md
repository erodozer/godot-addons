# Marquee Label

Horizontally scrolling Text Control like classic HTML Marquees.

Note: This component does not inherit from Label, as it uses a custom draw function.

## Usage

Add like any other Control node.

If rendering standalone, you will want to enable Clip Contents so you see the text scrolling smoothly within the control's bounds.
You can also simply nest a Marquee Label within another control that has clipping enabled.

Styling must be done using LabelSettings.  A LabelSettings is required otherwise the script will not run.
