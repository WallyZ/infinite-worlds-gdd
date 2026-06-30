# 1.4 Target Platforms & Devices

### **Primary Target: PC VR**

*Infinite Worlds* is designed as a **VR-first experience**, leveraging Unreal Engine’s rich support for immersive interactions, full-body inputs, and scalable performance.

---

### **Supported Headsets**

| Headset | Support Route | Specs | Approx. Price |
| --- | --- | --- | --- |
| Meta Quest 3 | PC Link via Air Link / Cable | 2064×2208 per-eye @90–120 Hz, Snapdragon XR2 Gen 2, ~515 g | ~$499 |
| Meta Quest 3S | PC Link | 1832×1920 per-eye @90–120 Hz, XR2 Gen 2, 514 g | $299–$399 |
| Meta Quest Pro | PC Link | 1800×1920 per-eye @72–90 Hz, XR2+, eye & face tracking, 722 g | ~$999 |
| Valve Index | SteamVR (OpenXR) | 1440×1600 per-eye @120 Hz, excellent controllers | ~$999 kit |
| HTC Vive Pro 2 | SteamVR | 2448×2448 per-eye @120 Hz, room-scale | ~$799–999 |
| HTC Vive XR Elite | PC Link / Wireless | 1920×1920 @90 Hz, XR2, 12 GB RAM, 128 GB storage, 625 g | ~$1,099 |
| Pimax (Crystal, Crystal Super, etc.) | SteamVR | Up to 4K per eye @160 Hz, 200° FOV | $1,599–1,695 |
| Pico 4 / 4 Ultra | PC VR via Link | 2160×2160 @90 Hz, XR2, ~586 g | ~$499–599 |
| PlayStation VR2 | PC via Adapter (SteamVR/OpenXR) | 2000×2040 per-eye @90/120 Hz, HDR OLED | ~$549 |
| Apple Vision Pro | PC via OpenXR bridge (limited) | 3660×3200 per-eye, micro-OLED, AR capable | >$3,500 |

---

### **Input Methods**

- Full 6DoF motion controllers with advanced tracking
- Hand tracking, eye tracking (where supported)
- Optional room-scale and seated modes

### **VR Priorities**

- Low-latency motion-to-photon (<20 ms)
- Embodied hand and body presence (gesture casting, climbing, crafting)
- Comfortable locomotion: teleport, smooth, hybrid
- Mid-to-high-end PC performance scalability

---

### **Secondary Target: Flat‑Screen PC (Non‑VR)**

Flat-screen desktop mode reinterprets core VR systems for keyboard/mouse and gamepad input:

- **Input Support:** Keyboard + mouse, Gamepads (Xbox, PlayStation)
- **Flat Mode Adjustments:**
    - UI overlays for diegetic info
    - Radial menus and input mappings for gestures or voice
- **Use Cases:**
    - Modding, server hosting, streaming
    - Expanded accessibility and traditional content creation

---

## ⚙️ Advanced VR Accessories & Integration

### 🧤 **Haptic Gloves**

| Device | Specs | Price | Link |
| --- | --- | --- | --- |
| SenseGlove Nova 2 | Force feedback, wireless, multi-actuator | ~$7,800 | [senseglove.com](https://www.senseglove.com/) |
| HaptX G1 Dev Kit | Microfluidic actuators, 6DoF, resistive feedback | ~$5,495 | [haptx.com](https://www.haptx.com/) |
| MANUS Prime 3 Haptic XR | 5 flex sensors, 6 IMUs, <7.5 ms latency | ~$1,900 | manus-meta.com |
| bHaptics TactGlove DK2 | 12 vibrotactile actuators | ~$249 | [bhaptics.com](https://www.bhaptics.com/) |
| WEART TouchDIVER Pro | Six-point haptics | ~$5,200 | [weartech.it](https://www.weartech.it/) |
| Fluid Reality Gloves *(Coming Soon)* | 160 fingertip actuators | TBD | [fluidreality.com](https://fluidreality.com/) |

### 🎽 **Haptic Suits & Vests**

| Device | Specs | Price | Link |
| --- | --- | --- | --- |
| bHaptics TactSuit X40 | 40 haptic points | ~$499–529 | [bhaptics.com](https://www.bhaptics.com/) |
| Teslasuit | EMS + motion capture + biometrics | Enterprise | [teslasuit.io](https://teslasuit.io/) |
| TrueGear Suit | Full torso coverage | ~$259 | [truegearsuit.com](https://www.truegearsuit.com/) |

### 🏃‍♂️ **VR Locomotion Platforms**

| Device | Specs | Price | Link |
| --- | --- | --- | --- |
| Virtuix Omni One | 360° treadmill, Pico 4U headset, motion harness | ~$2,595 | virtuix.com |
| KAT Walk C2 Series | Multiple harness types, 360 locomotion | ~$999–1,399 | [katvr.com](https://www.katvr.com/) |
| Cyberith Virtualizer | Omni treadmill with tilt sensors | TBD | [cyberith.com](https://www.cyberith.com/) |
| Infinadeck | True omnidirectional floor treadmill | Enterprise | [infinadeck.com](https://www.infinadeck.com/) |
| Wizdish ROVR | Slide-based motion ring + foot tracking | ~$600 | [wizdish.com](https://www.wizdish.com/) |

### 🔁 **Other XR Devices**

| Device | Specs | Use | Link |
| --- | --- | --- | --- |
| KiWear Smart Ring | Finger gesture input | UI control, quick-spell | [kiwear.com](https://kiwear.com/) |
| Sony XYN XR Headset | 8K display, precision ring controllers | Enterprise VR | TBD |

---

## 🔧 **Planned Integrations & Capabilities**

**Short-Term Plans:**

- Support bHaptics devices (TactSuit and TactGlove) using official Unreal Engine plugin
- Create modular Unreal input mapping for gloves (grab detection, spell gestures)
- Enable VR treadmill input mapping for Omni/KAT Walk through movement override

**Mid-Term Plans:**

- Add full-body presence and suit feedback (e.g., hit reaction, magic pulse, weather)
- Implement hand tracking fallbacks for smart rings and low-profile gesture inputs

**Long-Term & Experimental:**

- Investigate Teslasuit integration for elite combat and training modules
- Optional immersive settings layer for multi-device setups (glove + suit + treadmill)
- Procedural haptic feedback generator using Unreal's physics + audio cues

---

### 🗂 Summary

Your *Infinite Worlds* now supports:

- Full range of major **VR headsets** with OpenXR integration
- **Advanced haptics** (gloves, suits, vests)
- **Locomotion platforms** for immersive real-walking traversal
- Gesture/feedback tools for extended **interaction fidelity**
- Structured plans for integrating future XR hardware

> Info best suited for sections:
> 
> - "Haptics Integration & Profiles" (NEW Section 4.x)
> - "1.5 Design Philosophy" → add "Hardware Expansion Philosophy"
> - Appendix: "Supported Hardware Matrix" (detailed comparison table)

Let me know if you want these moved into those new sections or turned into implementation modules.