
// Google Maps Loader - Single Instance

class GoogleMapsLoader {

  constructor() {

    this.isLoading = false;

    this.isLoaded = false;

    this.callbacks = [];

  }

  load(apiKey, callback) {

    // Already loaded

    if (this.isLoaded && window.google && window.google.maps) {

      callback();

      return;

    }

    // Store callback

    if (callback) {

      this.callbacks.push(callback);

    }

    // Already loading

    if (this.isLoading) {

      return;

    }

    // Check for existing script

    const existing = document.querySelector('script[src*="maps.googleapis.com"]');

    if (existing) {

      console.log('✓ Google Maps script already exists');

      this.waitForLoad();

      return;

    }

    console.log('📥 Loading Google Maps API...');

    this.isLoading = true;

    const script = document.createElement('script');

    script.src = https://maps.googleapis.com/maps/api/js?key=${apiKey}&libraries=places&language=ja;

    script.async = true;

    script.defer = true;

    script.onload = () => {

      console.log('✅ Google Maps loaded');

      this.isLoaded = true;

      this.isLoading = false;

      this.runCallbacks();

    };

    script.onerror = () => {

      console.error('❌ Failed to load Google Maps');

      this.isLoading = false;

    };

    document.head.appendChild(script);

  }

  waitForLoad() {

    const check = setInterval(() => {

      if (window.google && window.google.maps) {

        clearInterval(check);

        this.isLoaded = true;

        this.isLoading = false;

        this.runCallbacks();

      }

    }, 100);

    // Timeout after 10 seconds

    setTimeout(() => clearInterval(check), 10000);

  }

  runCallbacks() {

    this.callbacks.forEach(cb => {

      try {

        cb();

      } catch (e) {

        console.error('Map callback error:', e);

      }

    });

    this.callbacks = [];

  }

}

// Global instance

window.mapsLoader = window.mapsLoader || new GoogleMapsLoader();

