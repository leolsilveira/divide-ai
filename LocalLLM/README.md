# Receipt Scanner App

## Overview

The Receipt Scanner app is an iOS application that allows users to:

1. Take a picture of a receipt (e.g., from a bar or restaurant)
2. Use iOS VisionKit to extract text from the receipt
3. Process the text using a local LLM to identify individual items and prices
4. Present a list of items with checkboxes for users to select which ones they want to pay for
5. Calculate and display a running subtotal as items are selected

## Implementation Details

The app has been implemented according to the architecture document, with the following components:

### Data Models

- `ReceiptItem`: Represents an individual item on a receipt with a label, amount, and selection state
- `Receipt`: Contains a collection of receipt items, raw text, image data, and methods for calculating totals
- `Model`: Handles LLM processing for receipt text analysis

### Services

- `ReceiptScanner`: Handles text recognition from images using VisionKit

### UI Views

- `WelcomeView`: Main landing page with app features and a button to start scanning
- `CameraView`: Camera interface for taking a picture of a receipt
- `ProcessingView`: Loading screen while processing the image and extracting items
- `ItemSelectionView`: List of extracted items with checkboxes for selection
- `SummaryView`: Final screen showing selected items and total

## Features

- **Modern UI**: Clean, intuitive interface focused on receipt scanning
- **Image Capture**: Take photos of receipts or select from the photo library
- **Text Recognition**: Extract text from receipt images using VisionKit
- **Item Extraction**: Process text using LLM to identify items and prices
- **Item Selection**: Select which items to include in your bill
- **Real-time Subtotal**: See your subtotal update as you select/deselect items
- **Sharing**: Share your bill summary with others

## How to Use

1. Launch the app and view the welcome screen
2. Tap "Scan Receipt" to begin
3. Take a photo of a receipt or select one from your photo library
4. Wait for the app to process the receipt and extract items
5. Select the items you want to pay for
6. View your bill summary and share if desired

## Technical Notes

- The app uses VisionKit for text recognition from images
- The local LLM (Llama 3.2) is used to extract items and prices from the receipt text
- The UI is built with SwiftUI for a modern, responsive interface
- The app follows a single-flow experience that guides users through the process

## Future Enhancements

As outlined in the architecture document, future enhancements could include:

- History feature to save past receipts
- Enhanced sharing capabilities
- Multiple selection profiles
- Receipt categorization
- Improved recognition for handwritten receipts