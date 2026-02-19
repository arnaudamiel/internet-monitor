package main

import (
	"fmt"
	"net"
	"os"
	"time"
)

const (
	logFile       = "internet_outages.log"
	checkInterval = 1 * time.Second
	threshold     = 5            // Number of failed attempts before declaring failure to avoid jitter
	targetAddr    = "8.8.8.8:53" // Google DNS
	altAddr       = "1.1.1.1:53" // Cloudflare DNS
	timeout       = 1 * time.Second
)

func main() {
	isDown := false
	var downStart time.Time

	// Track consecutive failures
	failCount := 0

	fmt.Printf("Monitoring internet connection... Logging to %s\n", logFile)

	for {
		err := checkConnection()

		if err != nil {
			// Increment failures if the check failed
			failCount++

			// Only trigger "Down" if we hit the threshold and aren't already down
			if failCount >= threshold && !isDown {
				isDown = true
				// Back-date the outage start to when the first failure actually happened
				downStart = time.Now().Add(-time.Duration(threshold) * time.Second)
				fmt.Println("!!! Internet is officially DOWN")
			}
		} else {
			// Success! Check if we were previously in an outage
			if isDown {
				isDown = false
				duration := time.Since(downStart)
				logOutage(downStart, duration)
				fmt.Printf("+++ Internet is BACK (Outage lasted %v)\n", duration.Round(time.Second))
			}
			// Reset the counter on any successful connection
			failCount = 0
		}

		time.Sleep(checkInterval)
	}
}

func checkConnection() error {
	// Try the first address
	conn, err := net.DialTimeout("tcp", targetAddr, timeout)
	if err == nil {
		conn.Close() // Success! Close it and return
		return nil
	}

	// If the first failed, try the second address
	conn, err = net.DialTimeout("tcp", altAddr, timeout)
	if err == nil {
		conn.Close() // Success! Close it and return
		return nil
	}

	// Both failed, return the last error
	return err
}

func logOutage(start time.Time, duration time.Duration) {
	f, err := os.OpenFile(logFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Printf("Error opening log: %v\n", err)
		return
	}
	defer f.Close()

	timestamp := start.Format("2006-01-02 15:04:05")
	logEntry := fmt.Sprintf("[%s] Outage detected! Duration: %s\n", timestamp, duration.Round(time.Second))

	f.WriteString(logEntry)
}
