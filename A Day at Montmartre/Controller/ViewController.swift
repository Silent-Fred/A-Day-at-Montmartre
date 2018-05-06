//
//  ViewController.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 27.12.17.
//  Copyright © 2017 Michael Kühweg. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var theMainView: UIView!
    @IBOutlet weak var theTarget: UIImageView!
    @IBOutlet weak var theCurrentState: UIImageView!

    @IBOutlet weak var orbits: UIImageView!

    @IBOutlet weak var toolbar: UIToolbar!

    @IBOutlet weak var playPauseButton: UIButton!

    let imagePicker = UIImagePickerController()

    private let refreshInterval = TimeInterval(0.1)
    private var refreshTimer = Timer()

    private var approximator: Approximator?
    private var approximating: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        theTarget.layer.borderWidth = 5
        theTarget.layer.borderColor = UIColor.white.cgColor

        imagePicker.delegate = self

        // pick the image that is set in the storyboard and handle it just the
        // way it would be if it were taken from the photo library
        // (force unwrap is not nice, but hey, it's the image set in
        // the storyboard, so if it should be missing - SET IT)
        pickImageAndVisuallyRestartApproximation(image: theTarget.image!)

        refreshProgressLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func photoFromLibrary(_ sender: UIBarButtonItem) {
        stopApproximation()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func shareCurrent(_ sender: UIBarButtonItem) {
        stopApproximation()
        shareCurrentApproximation()
    }

    @IBAction func startPauseApproximation() {
        togglePlayPauseButton()
        refreshApproximationStateAndContinue()
    }

    @IBAction func callSettings() {
        if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(appSettings)
        }
    }

    private func shareCurrentApproximation() {

        guard let safeImage = approximator?.currentImage else { return }

        let imageToShare = [ safeImage ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare,
                                                              applicationActivities: nil)
        // according to stackoverflow, the following is required so that iPads won't crash
        activityViewController.popoverPresentationController?.sourceView = self.view

        // exclude some activity types from the list
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToFlickr,
            UIActivityType.postToTencentWeibo,
            UIActivityType.postToVimeo,
            UIActivityType.postToWeibo
        ]

        self.present(activityViewController, animated: true, completion: nil)
    }

    func startApproximation() {
        approximating = true
        playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
        startRefreshTimer()
    }

    func stopApproximation() {
        approximating = false
        playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
        stopRefreshTimer()
    }

    func restartApproximatorIfSettingsChanged() {
        if settingsChanged() {
            restartApproximatorWithCurrentSettings(imageToApproximate: theTarget.image)
        }
    }

    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(
            timeInterval: refreshInterval,
            target: self,
            selector: (#selector(ViewController.refreshProgressLabel)),
            userInfo: nil,
            repeats: true)
        refreshTimer.tolerance = 1
    }

    private func stopRefreshTimer() {
        refreshTimer.invalidate()
    }

    private func restartApproximatorWithCurrentSettings(imageToApproximate: UIImage?) {

        guard let imageToApproximate = imageToApproximate else { return }

        let approximationStyle = SettingsBundleHelper.approximationStyle()
        let shapeStyle = SettingsBundleHelper.shapeStyle() ?? .ellipses
        if approximationStyle == ApproximationStyle.basicEvolutionary {
            approximator = BasicEvolutionaryApproximator(imageToApproximate: imageToApproximate,
                                                         using: shapeStyle)
        } else {
            approximator = HillClimbApproximator(imageToApproximate: imageToApproximate,
                                                 using: shapeStyle)
        }
    }

    private func settingsChanged() -> Bool {
        return approximationStyleSettingsChanged()
            || shapeStyleSettingsChanged()
    }

    private func approximationStyleSettingsChanged() -> Bool {

        guard approximator != nil else { return false }

        switch SettingsBundleHelper.approximationStyle() {
        case .basicEvolutionary?:
            return !(approximator is BasicEvolutionaryApproximator)
        default:
            return !(approximator is HillClimbApproximator)
        }
    }

    private func shapeStyleSettingsChanged() -> Bool {

        guard let approximatorUsesShape = approximator?.shapesToUse
            else { return true }
        guard let bundleSuggestsShape = SettingsBundleHelper.shapeStyle()
            else { return false }

        return approximatorUsesShape != bundleSuggestsShape
    }

    private func refreshApproximationStateAndContinue() {
        if approximating {
            refreshApproximationState()
            let queue = DispatchQueue(label: "de.kuehweg.montmartre.approximatorQueue",
                                      qos: .userInitiated)
            queue.async {
                self.approximator?.refineApproximation()
                DispatchQueue.main.async {
                    self.refreshApproximationStateAndContinue()
                }
            }
        }
    }

    private func refreshApproximationState() {
        refreshProgressLabel()
        theTarget.image = approximator?.targetImage
        theCurrentState.image = approximator?.currentImage
    }

    private func togglePlayPauseButton() {
        if approximating {
            stopApproximation()
        } else {
            startApproximation()
        }
    }

    @objc private func refreshProgressLabel() {

        orbits.isHidden = !approximating
        if let safeApproximator = approximator {
            let shapes = safeApproximator.shapeCount
            // TODO maybe add some of these values later
            // let attempts = safeApproximator.approximationAttempts
            // let rating = safeApproximator.approximationRatingInPercent()
            // let ratingFormatted = String(format: "%.1f", rating)
            // let detail = safeApproximator.detailLevel()
            var orbitNumber = OrbitNumberImage(Double(shapes), orbits: 3)
            orbitNumber.numberColour = self.view.tintColor
            orbits.image = orbitNumber.image(width: Int(orbits.frame.width),
                                             height: Int(orbits.frame.height))
        }
    }

    private func pickImageAndVisuallyRestartApproximation(image: UIImage) {
        restartApproximatorWithCurrentSettings(imageToApproximate: image)
        // visualise
        theTarget.image = image
        theTarget.layer.borderColor =
            averageColourOf(approximator?.targetScaledImage).cgColor
        // initially always show the title image
        theCurrentState.image = UIImage(named: "Title")
        refreshProgressLabel()
    }

    private func averageColourOf(_ image: UIImage?) -> UIColor {

        guard let safeImage = image?.cgImage
            else { return UIColor.white }

        let bitmap = BitmapMagic(forImage: safeImage)
        let averageColour = bitmap.colourCloud().averageColour()
        return averageColour.uiColor()
    }

    // MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickImageAndVisuallyRestartApproximation(image: image)
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}