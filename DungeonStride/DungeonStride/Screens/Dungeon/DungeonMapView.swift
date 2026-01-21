//
//  DungeonMapView.swift
//  DungeonStride
//
//  Created by Vit Cevelik on 03.11.2025.
//

import SwiftUI
import UIKit

struct DungeonMapView: View {
    @StateObject private var viewModel = DungeonMapViewModel()

    // Zoom tlačítka
    @State private var zoomTrigger: ZoomAction? = nil
    enum ZoomAction { case zoomIn, zoomOut }

    var body: some View {
        NavigationView {
            ZStack {
                // 1. Vrstva: Mapa (Pozadí)
                // Musí být jako první v ZStacku
                MapUIKitWrapper(viewModel: viewModel, zoomTrigger: $zoomTrigger)
                    .edgesIgnoringSafeArea(.all)  // Důležité: Ignoruje vše (i nahoře pod navigací)

                // 2. Loading Indicator
                if viewModel.isLoading {
                    ProgressView("Načítám mapu...")
                        .scaleEffect(1.5)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }

                // 3. Chybová hláška
                if let error = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                }

                // 4. Ovládání zoomu
                if !viewModel.isLoading {
                    zoomButtonsOverlay
                }
            }
            // Nastavení Navigace
            .navigationTitle(
                viewModel.mapName.isEmpty ? "Mapa" : viewModel.mapName
            )
            .navigationBarTitleDisplayMode(.inline)
            // Udělá navigaci průhlednou, aby pod ní byla vidět mapa
            .toolbarBackground(.hidden, for: .navigationBar)
            // Nastaví text navigace na bílý (dark mode style), aby byl vidět na tmavé mapě
            .toolbarColorScheme(.dark, for: .navigationBar)

            // Bottom Sheet
            .sheet(item: $viewModel.selectedLocation) { location in
                LocationDetailSheet(location: location, viewModel: viewModel)
                    .presentationDetents([.fraction(0.35)])
                    .presentationCornerRadius(24)
                    .presentationDragIndicator(.visible)
            }
        }
        .navigationViewStyle(.stack)
    }

    private var zoomButtonsOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    Button {
                        zoomTrigger = .zoomIn
                    } label: {
                        Image(systemName: "plus").zoomBtnStyle()
                    }
                    Button {
                        zoomTrigger = .zoomOut
                    } label: {
                        Image(systemName: "minus").zoomBtnStyle()
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

extension Image {
    func zoomBtnStyle() -> some View {
        self.font(.title2).bold().foregroundColor(.black)
            .frame(width: 50, height: 50)
            .background(Color.white.opacity(0.9))
            .clipShape(Circle())
            .shadow(radius: 4)
    }
}

// MARK: - UIKit Wrapper
struct MapUIKitWrapper: UIViewRepresentable {
    @ObservedObject var viewModel: DungeonMapViewModel
    @Binding var zoomTrigger: DungeonMapView.ZoomAction?

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator

        // Základní konfigurace
        scrollView.bouncesZoom = false  // Vypneme "pružení" při oddálení (chceš fixní limit)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .black

        // Klíčové nastavení pro mapu pod navigací
        scrollView.contentInsetAdjustmentBehavior = .never

        let containerView = UIView()
        scrollView.addSubview(containerView)

        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        containerView.addSubview(imageView)

        // Tap Gesture
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleMapTap(_:))
        )
        imageView.addGestureRecognizer(tap)

        context.coordinator.scrollView = scrollView
        context.coordinator.containerView = containerView
        context.coordinator.imageView = imageView

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        let coordinator = context.coordinator

        // 1. Zoom Trigger
        if let action = zoomTrigger {
            DispatchQueue.main.async {
                action == .zoomIn ? coordinator.zoomIn() : coordinator.zoomOut()
                self.zoomTrigger = nil
            }
        }

        // 2. Nastavení velikosti obsahu
        let mapSize = viewModel.mapSize
        // Ochrana proti nulové velikosti
        let safeSize =
            mapSize.width > 0 ? mapSize : CGSize(width: 1000, height: 1000)

        if coordinator.containerView?.frame.size != safeSize {
            coordinator.containerView?.frame = CGRect(
                origin: .zero,
                size: safeSize
            )
            coordinator.imageView?.frame = CGRect(origin: .zero, size: safeSize)
            uiView.contentSize = safeSize
        }

        // 3. Načtení obrázku
        if coordinator.currentMapName != viewModel.mapImageName
            || coordinator.imageView?.image == nil
        {
            if !viewModel.mapImageName.isEmpty {
                if let image = UIImage(named: viewModel.mapImageName) {
                    coordinator.imageView?.image = image
                    coordinator.currentMapName = viewModel.mapImageName
                }
            }
        }

        // 4. Aktualizace Zoomu a Layoutu
        // Toto se volá při každé změně, aby se přepočítal min/max zoom podle velikosti obrazovky
        if uiView.bounds.width > 0 {
            // Pokud jsme ještě nenastavili úvodní zoom, uděláme to teď
            if !coordinator.hasInitialZoomDone {
                DispatchQueue.main.async {
                    coordinator.configureZoom(initial: true)
                }
            } else {
                // Pokud se změnila velikost okna (rotace), jen přepočítáme minZoom
                coordinator.configureZoom(initial: false)
            }
        }

        // 5. Vykreslení obsahu
        if coordinator.pathCount != viewModel.paths.count {
            coordinator.drawPaths(paths: viewModel.paths)
            coordinator.pathCount = viewModel.paths.count
        }

        if coordinator.locationCount != viewModel.locations.count {
            coordinator.drawPins(locations: viewModel.locations)
            coordinator.locationCount = viewModel.locations.count
        }

        if let travelPath = viewModel.travelPath {
            coordinator.movePlayerAlongPath(travelPath)
        } else {
            coordinator.updatePlayerPosition(viewModel.playerPosition)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: - Coordinator
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: MapUIKitWrapper
        weak var scrollView: UIScrollView?
        weak var containerView: UIView?
        weak var imageView: UIImageView?

        var playerView: UIView?
        var pathsLayer: CAShapeLayer?
        var activePathLayer: CAShapeLayer?

        var currentMapName = ""
        var pathCount = -1
        var locationCount = -1
        var hasInitialZoomDone = false

        init(_ parent: MapUIKitWrapper) { self.parent = parent }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            containerView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerContent(scrollView)
        }

        // Tato funkce zajistí, že mapa je vždy uprostřed, pokud je zoom menší než obrazovka
        private func centerContent(_ scrollView: UIScrollView) {
            guard let container = containerView else { return }
            let boundsSize = scrollView.bounds.size
            var frameToCenter = container.frame

            // Horizontálně
            if frameToCenter.size.width < boundsSize.width {
                frameToCenter.origin.x =
                    (boundsSize.width - frameToCenter.size.width) / 2
            } else {
                frameToCenter.origin.x = 0
            }

            // Vertikálně
            if frameToCenter.size.height < boundsSize.height {
                frameToCenter.origin.y =
                    (boundsSize.height - frameToCenter.size.height) / 2
            } else {
                frameToCenter.origin.y = 0
            }

            container.frame = frameToCenter
        }

        // HLAVNÍ FUNKCE PRO VÝPOČET ZOOMU
        func configureZoom(initial: Bool) {
            guard let sv = scrollView, let container = containerView else {
                return
            }

            let boundsSize = sv.bounds.size
            let contentSize = container.bounds.size

            // 🛑 POJISTKA PROTI ČERNÉ OBRAZOVCE (Dělení nulou)
            guard boundsSize.width > 0, boundsSize.height > 0,
                contentSize.width > 0
            else { return }

            let scaleWidth = boundsSize.width / contentSize.width
            let scaleHeight = boundsSize.height / contentSize.height

            // 1. Min Scale = Aspect Fit (Přesně na kraje, žádné prázdné místo)
            let minScale = min(scaleWidth, scaleHeight)

            sv.minimumZoomScale = minScale
            sv.maximumZoomScale = 4.0

            if initial {
                // Startovní zoom trochu přiblížený (1.5x minima)
                let startScale = minScale * 1.5
                sv.zoomScale = startScale

                // Vycentrovat
                let contentWidth = contentSize.width * startScale
                let contentHeight = contentSize.height * startScale
                let centerX = (contentWidth - boundsSize.width) / 2
                let centerY = (contentHeight - boundsSize.height) / 2
                sv.contentOffset = CGPoint(
                    x: max(0, centerX),
                    y: max(0, centerY)
                )

                self.hasInitialZoomDone = true
            } else {
                // Pokud uživatel oddálil víc, než je nově povolené minimum, vrátíme ho zpět
                if sv.zoomScale < minScale {
                    sv.setZoomScale(minScale, animated: true)
                }
            }

            // Vždy vycentrovat
            centerContent(sv)
        }

        // --- Interakce ---
        @objc func handleMapTap(_ sender: UITapGestureRecognizer) {
            let loc = sender.location(in: sender.view)
            print("🎯 SOUŘADNICE: \"x\": \(Int(loc.x)), \"y\": \(Int(loc.y))")
        }

        func zoomIn() {
            guard let sv = scrollView else { return }
            let newScale = min(sv.maximumZoomScale, sv.zoomScale * 1.5)
            sv.setZoomScale(newScale, animated: true)
        }

        func zoomOut() {
            guard let sv = scrollView else { return }
            // Nikdy nejdeme pod minimum
            let newScale = max(sv.minimumZoomScale, sv.zoomScale / 1.5)
            sv.setZoomScale(newScale, animated: true)
        }

        // --- Kreslení (Cesty, Piny, Hráč) ---
        func drawPaths(paths: [PathConnection]) {
            guard let container = containerView else { return }
            pathsLayer?.removeFromSuperlayer()
            let layer = CAShapeLayer()
            let bezier = UIBezierPath()
            for path in paths {
                let (p, _) = createBezier(from: path)
                bezier.append(p)
            }
            layer.path = bezier.cgPath
            layer.strokeColor = UIColor.brown.withAlphaComponent(0.5).cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = 5
            layer.lineDashPattern = [10, 10]
            layer.lineCap = .round
            if let sub = container.layer.sublayers, sub.count > 0 {
                container.layer.insertSublayer(layer, at: 1)
            } else {
                container.layer.addSublayer(layer)
            }
            self.pathsLayer = layer
        }

        func createBezier(from pathData: PathConnection) -> (
            UIBezierPath, CGPoint
        ) {
            let path = UIBezierPath()
            let start = pathData.from
            let end = pathData.to
            path.move(to: start)
            let midX = (start.x + end.x) / 2
            let midY = (start.y + end.y) / 2
            let dx = end.x - start.x
            let dy = end.y - start.y
            let dist = hypot(dx, dy)
            let factor = pathData.curveAmount * (dist / 2)
            let len = hypot(dy, dx)
            let safeLen = len > 0 ? len : 1
            let controlX = midX - (dy / safeLen) * factor
            let controlY = midY + (dx / safeLen) * factor
            let cp = CGPoint(x: controlX, y: controlY)
            path.addQuadCurve(to: pathData.to, controlPoint: cp)
            return (path, cp)
        }

        func movePlayerAlongPath(_ pathData: PathConnection) {
            guard let container = containerView else { return }
            if playerView == nil { updatePlayerPosition(pathData.from) }
            guard let player = playerView else { return }

            let (path, _) = createBezier(from: pathData)
            activePathLayer?.removeFromSuperlayer()
            let highlight = CAShapeLayer()
            highlight.path = path.cgPath
            highlight.strokeColor = UIColor.orange.cgColor
            highlight.lineWidth = 4
            highlight.fillColor = UIColor.clear.cgColor
            highlight.lineCap = .round
            highlight.lineDashPattern = [8, 6]
            highlight.strokeEnd = 0
            container.layer.insertSublayer(highlight, below: player.layer)
            self.activePathLayer = highlight

            let draw = CABasicAnimation(keyPath: "strokeEnd")
            draw.fromValue = 0
            draw.toValue = 1
            draw.duration = 2.0
            draw.fillMode = .forwards
            draw.isRemovedOnCompletion = false
            highlight.add(draw, forKey: "d")

            let move = CAKeyframeAnimation(keyPath: "position")
            move.path = path.cgPath
            move.duration = 2.0
            move.fillMode = .forwards
            move.isRemovedOnCompletion = false

            CATransaction.begin()
            CATransaction.setCompletionBlock {
                player.center = pathData.to
                highlight.removeFromSuperlayer()
            }
            player.layer.add(move, forKey: "m")
            CATransaction.commit()
        }

        func updatePlayerPosition(_ pos: CGPoint) {
            guard let container = containerView else { return }
            if playerView == nil {
                let i = UIImageView(
                    image: UIImage(systemName: "figure.walk.circle.fill")
                )
                i.tintColor = .systemBlue
                i.backgroundColor = .white
                i.layer.cornerRadius = 22
                i.layer.masksToBounds = true
                i.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
                i.layer.borderWidth = 2
                i.layer.borderColor = UIColor.white.cgColor
                i.layer.shadowColor = UIColor.black.cgColor
                i.layer.shadowOpacity = 0.5
                i.layer.shadowRadius = 4
                i.layer.shadowOffset = CGSize(width: 0, height: 2)
                container.addSubview(i)
                self.playerView = i
            }
            playerView?.center = pos
        }

        func drawPins(locations: [GameMapLocation]) {
            guard let container = containerView else { return }
            container.subviews.forEach { view in
                if view is UIButton || view.tag == 777 {
                    view.removeFromSuperview()
                }
            }
            for loc in locations {
                let btnSize: CGFloat = 60
                let btn = UIButton(type: .custom)
                let conf = UIImage.SymbolConfiguration(
                    pointSize: 30,
                    weight: .bold
                )
                btn.setImage(
                    UIImage(
                        systemName: iconForType(loc.locationType),
                        withConfiguration: conf
                    ),
                    for: .normal
                )
                btn.tintColor = colorForType(loc.locationType)
                btn.backgroundColor = .white
                btn.layer.cornerRadius = btnSize / 2
                btn.layer.shadowOpacity = 0.4
                btn.layer.shadowOffset = CGSize(width: 0, height: 4)
                btn.frame = CGRect(
                    x: loc.x - btnSize / 2,
                    y: loc.y - btnSize / 2,
                    width: btnSize,
                    height: btnSize
                )
                btn.addAction(
                    UIAction { [weak self] _ in
                        self?.parent.viewModel.selectLocation(loc)
                    },
                    for: .touchUpInside
                )
                container.addSubview(btn)

                let lbl = UILabel()
                lbl.text = loc.name
                lbl.font = .boldSystemFont(ofSize: 13)
                lbl.textColor = .white
                lbl.backgroundColor = UIColor(white: 0, alpha: 0.7)
                lbl.layer.cornerRadius = 6
                lbl.clipsToBounds = true
                lbl.sizeToFit()
                lbl.frame = lbl.frame.insetBy(dx: -8, dy: -4)
                lbl.center = CGPoint(x: loc.x, y: loc.y + (btnSize / 2) + 16)
                lbl.tag = 777
                container.addSubview(lbl)
            }
        }

        func iconForType(_ type: String) -> String {
            switch type {
            case "city": return "house.lodge.fill"
            case "dungeon": return "lock.shield.fill"
            default: return "mappin.circle.fill"
            }
        }
        func colorForType(_ type: String) -> UIColor {
            switch type {
            case "city": return .systemBlue
            case "dungeon": return .systemRed
            default: return .systemGray
            }
        }
    }
}

// Sub-view pro Bottom Sheet
struct LocationDetailSheet: View {
    let location: GameMapLocation
    @ObservedObject var viewModel: DungeonMapViewModel

    var body: some View {
        VStack(spacing: 20) {
            Capsule().fill(Color.gray.opacity(0.4)).frame(width: 40, height: 5)
                .padding(.top, 10)
            HStack {
                VStack(alignment: .leading) {
                    Text(location.name).font(.title).bold()
                    Text(location.locationType.uppercased()).font(.caption)
                        .fontWeight(.semibold).foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            Divider()
            if let desc = location.description {
                Text(desc).font(.body).multilineTextAlignment(.leading).padding(
                    .horizontal
                )
            }
            Spacer()
            Button(action: { viewModel.travelToSelectedLocation() }) {
                HStack {
                    Image(systemName: "figure.walk")
                    Text("Cestovat sem")
                }
                .frame(maxWidth: .infinity).padding().background(Color.blue)
                .foregroundColor(.white).cornerRadius(12)
            }
            .padding(.horizontal).padding(.bottom, 20)
        }
    }
}
