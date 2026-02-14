
## UUID
The service and characteristic UUIDs for HR and HRV are

`a0262760-08c2-11e1-9073-0e8ac72e1234 = service UUID`
`a0262760-08c2-11e1-9073-0e8ac72e0001 = characteristic UUID`

- `STARTTEMP` : This will starts the temperature data streaming every 5 second.
- `STOPTEMP` : This will stop the streaming temp data.


- 0x`15-80` = 5504
- 5504*0.005=27.52 C



### UUIDs
The service and characteristic UUIDs are:
- `4e771a15-2665-cf92-9073-8c64a4ab357` = service UUID
- `48837cb0-b733-7c24-31b7-222222222222` = characteristic UUID
#### Commands 
- "STARTSTS40":  Starts the Temperature data streaming.
-  "STOPSTS40": Stops the streaming.


## UUID
The service and characteristic UUIDs for SigMot are

`a0262760-08c2-11e1-9073-0e8ac72e1234 = service UUID
`a0262760-08c2-11e1-9073-0e8ac72e0001 = characteristic UUID`

## Commands:

→ To receive SigMot data, send "sigmot" to the above `characteristic UUID` .

→ The command will continue running automatically.

## Received Data:

After sending the command, you'll receive an array of numbers representing significant motion events.

Example: [12,10,4,0,0,0,0,0,1,3,5] — The first number (12) shows significant motions detected in the first 30 seconds, the second number (10) shows motions in the next 30 seconds, and so on.

### ### Version Table

| Version | Author    | Published Date | Comments |
| ------- | --------- | -------------- | -------- |
| 1.0     | Karthik P | Feb 4, 2025    |          |


## Commands:

- STARTSHRD: Initiates streaming of Sensor Hub raw data to BLE notification.
- STOPSHRD: Terminates the streaming of Sensor Hub raw data.

## Steps to Retrieve Sensor Hub Data:

1. Subscribe to the custom service notification.
2. Send the command "STARTSHRD".
3. Receive the Sensor Hub raw data in this format:

```
2be6022a27164ea516485625f84325f276ff22029d02bc0002c66400000000000000000000000000000003
```

- The first 18 bytes contain PPG data, followed by 6 bytes of accelerometer data. The remaining data will be explained in the table below.
- The PPG data comprises 6 samples, each occupying 3 bytes. The breakdown is as follows: • First 6 bytes: Two green LED samples (PD1 and PD2) • Next 6 bytes: Two IR LED samples • Final 6 bytes: Two red LED samples
- The accelerometer data starts at the 19th byte: • Bytes 19–20: X-axis data • Bytes 21–22: Y-axis data • Bytes 23–24: Z-axis data

4. To stop the Sensor Hub raw data stream, send the command "STOPSHRD".
5. In a single shot, the device sends 30 samples of sensor hub raw data with an MTU size of 450 bytes. Each sample is 44 bytes, resulting in 1320 bytes for 30 samples (30 * 44 = 1320). After the 30th sample, the device sends the temperature data.
### Single Sensor Hub Data Sample 
| Bytes                                                      | Tags                   | Number of bytes |
| ---------------------------------------------------------- | ---------------------- | --------------- |
| 0th to 2nd                                                 | Green LED PD 1         | 3               |
| 3rd to 5th                                                 | Green LED PD 2         | 3               |
| 6th to 8th                                                 | IR LED PD 1            | 3               |
| 9th to 11th                                                | IR LED PD 2            | 3               |
| 12th to 14th                                               | Red LED PD 1           | 3               |
| 12th to 14th                                               | Red LED PD 2           | 3               |
| 18th to 19th                                               | X axis                 | 2               |
| 20th to 21th                                               | Y axis                 | 2               |
| 22th to 23th                                               | Z axis                 | 2               |
| 24th byte                                                  | current operating mode | 1               |
| 25th and 26th                                              | hr                     | 2               |
| 27th                                                       | hr_conf                | 1               |
| 28th and 29th                                              | rr                     | 2               |
| 30th                                                       | rr_conf                | 1               |
| 31th                                                       | activity class         | 1               |
| 32th and 33th                                              | r                      | 2               |
| 34th                                                       | spo2 conf              | 1               |
| 35th and 36th                                              | spo2                   | 2               |
| 37th                                                       | percentage complete    | 1               |
| 38th                                                       | lowSignal quality Flag | 1               |
| 39th                                                       | motion flag            | 1               |
| 40th                                                       | low pi flag            | 1               |
| 41th                                                       | unreliable flag        | 1               |
| 42th                                                       | SCD contact state      | 1               |
|                                                            | Total bytes            | 44              |
| Note: last Byte 1320 byte will be the temperature reading. |                        |                 |
### Version
|Version|Author|Published Date|Comments|
|---|---|---|---|
|1.0|Karthik P|Sep 30 2024||
|1.1|Karthik P|Nov 11 2024|MTU size is updated to 450 bytes|



#### Command
- STARTBMP:N : Starts the pressure sensor data streaming. X is a sampling rate.
- STOPBMP: To stop the streaming.
### UUIDs
The service and characteristic UUIDs are:
- `4e771a15-2665-cf92-9073-8c64a4ab357` = service UUID
- `48837cb0-b733-7c24-31b7-222222222222` = characteristic UUID

| N in Hz | Code |
| ------- | ---- |
| 0.25    | 30   |
| 1       | 28   |
| 3       | 26   |
| 5       | 24   |
| 15      | 22   |
| 25      | 20   |
| 35      | 18   |
| 45      | 16   |
| 60      | 14   |
| 80      | 12   |
| 100     | 10   |
| 120     | 8    |
| 140     | 6    |
| 160     | 4    |
| 200     | 2    |
| 240     | 0    |
#### Date Format
- 8 bytes of data is one frame:
	- First 4 bytes are pressure data. Convert it in to unsigned int value.
	- Last 4 bytes are temperature data. Convert it in to unsigned int.

### Version Table

| Version | Author    | Published Date | Comments |
| ------- | --------- | -------------- | -------- |
| 1.0     | Karthik P | Jan 15, 2026   |          |



## UUIDs

The IMU task uses the following service and characteristic UUIDs:

- **Service UUID:** `4e771a15-2665-cf92-9073-8c64a4ab357`
- **Characteristic UUID:** `48837cb0-b733-7c24-31b7-222222222222`

## Commands

- **Start IMU:**  
	Send `STARTIMU:X1_X2_X3_X4`  
	- `X1`: Output data rate  
	- `X2`: G scale  
	- `X3`: Gyroscope range  
	- `X4`: Sample averaging

- **Stop IMU:**  
	Send `STOPIMU`

### Command Parameters

#### X1: Output Data Rate

| Frequency | Byte Value |
|-----------|------------|
| 0.7 Hz    | 0x01       |
| 1.5 Hz    | 0x02       |
| 3 Hz      | 0x03       |
| 6 Hz      | 0x04       |
| 12 Hz     | 0x05       |
| 25 Hz     | 0x06       |
| 50 Hz     | 0x07       |
| 100 Hz    | 0x08       |
| 200 Hz    | 0x09       |
| 400 Hz    | 0x0A       |
| 800 Hz    | 0x0B       |
| 1.6 KHz   | 0x0C       |
| 3.2 KHz   | 0x0D       |
| 6.4 KHz   | 0x0E       |

#### X2: G Scale

| G Scale | Byte Value           |
| ------- | -------------------- |
| ±2g     | 0x00 (BMI323_FS_2G)  |
| ±4g     | 0x01 (BMI323_FS_4G)  |
| ±8g     | 0x02 (BMI323_FS_8G)  |
| ±16g    | 0x03 (BMI323_FS_16G) |

#### X3: Gyroscope Range

| Gyroscope Range | Byte Value                |
| --------------- | ------------------------- |
| ±125°/s         | 0x00 (BMI323_125_DEGREE)  |
| ±250°/s         | 0x01 (BMI323_250_DEGREE)  |
| ±500°/s         | 0x02 (BMI323_500_DEGREE)  |
| ±1000°/s        | 0x03 (BMI323_1000_DEGREE) |
| ±2000°/s        | 0x04 (BMI323_2000_DEGREE) |

#### X4: Sample Averaging

| Samples | Byte Value |
| ------- | ---------- |
| 1       | 0x0        |
| 2       | 0x1        |
| 4       | 0x2        |
| 8       | 0x3        |
| 16      | 0x4        |
| 32      | 0x5        |
| 64      | 0x6        |

### Data Format

IMU raw data is transmitted as follows:
Data format: big endian
- The first 6 bytes represent accelerometer data (X, Y, Z axes; 2 bytes per axis).
- The next 6 bytes represent gyroscope data (X, Y, Z axes; 2 bytes per axis).
- This pattern repeats for each sample.
- Ex: (2 bytes x-acc)-(2 bytes x-acc)-(2 bytes x-acc)-(2 bytes x-gyro)-(2 bytes x-gyro)-(2 bytes x-gyro)......continuous.
- 2's compliment is needed before plotting.
- 
### Version Table

| Version | Author    | Published Date | Comments |
| ------- | --------- | -------------- | -------- |
| 1.0     | Karthik P | Dec 01, 2025   |          |




## Commands:

STARTECG:N : Initiates ECG data transmission via notification.

- **Note**: `N` is a variable that can be set to 60, 100, 200, 500, or 1K.

STARTECG_F:100 : This command retrieves the filtered ECG signal.

**STOPECG**: Stops ECG data notification.

---

### Steps to Retrieve ECG Data

1. **Subscribe** to the custom notification.
    
2. **Send the STARTECG command** (use all caps and no spaces). Example: `STARTECG:200`.
    
3. ECG data will now be received in hex format. Example data stream:
    
    ```
    10-14-25-20-23-6D-00-37-44-10-15-83-20-25-84-00-3A-75-10-17-BD-20-26...
    ```
    
4. The data is transmitted continuously until you send the STOPECG command.
    
5. **Send the STOPECG command** to stop receiving ECG data.
    
6. **Unsubscribe** from the notification to halt further transmissions.
    
7. ECG Data automatically stops after 30 seconds.
    

---

### ECG Data Format

- Each ECG data packet is received in hexadecimal format.
    
- Example packet:
    
    ```
    10-14-25-20-23-6D-00-37-44-10-15-83-20-25...
    ```
    
    - **Hex data** represents the sensor output. Each hex group (e.g., `10-14`) represents an ECG sample.

---

### Understanding the ECG Data

The MTU size remains constant at 100 bytes for various sampling rates:

- 60 Hz
- 100 Hz
- 200 Hz
- 500 Hz
- 1 kHz

---

### Cases Where ECG Data Is Unavailable

- If the **TEMP_HRM task** is running, ECG data will not be available. The ECG task will run after the TEMP_HRM task is complete.

---

### Version Table
|Version|Author|Published Date|Comments|
|---|---|---|---|
|1.0|Karthik P|Oct 8, 2024||
|1.1|Karthik P|Oct 23, 2024|MTU size remains constant for all ECG sampling frequencies due to irregular FIFO filling caused by the sensor hub's low power mode.|
|1.2|Karthik P|Nov 7, 2024|there is no window limit to send the start ECG command just send the command wait for the data|
|2.0|Karthik P|Dec 30, 2024|A new filtered ECG signal feature is available at 128 Hz sampling rate only.|



### UUIDs
The service and characteristic UUIDs are:
- `4e771a15-2665-cf92-9073-8c64a4ab357` = service UUID
- `48837cb0-b733-7c24-31b7-222222222222` = characteristic UUID

### Commands
- To start, send: `"STARTECG_F:100"`
- To stop, send: `"STOPECG"`

**Note**: These are the same commands as in [[OD - ECG Raw Data Commands]] for filtered ECG. The difference is that previously only filtered ECG data was sent, but now ECG data, along with HR, HRV, and R_R intervals, is transmitted to the same service.

### Data Frame
Once the start command is sent, the user will receive two types of notifications distinguished by size:
- **> 200 bytes**: ECG data
- **< 100 bytes**: HR and HRV data or Impedance (Z)
  - If it is 4 bytes, then it is Z (impedance value), which represents the quality of contact between electrodes and skin. This needs to be classified in the future, but for now, just plot these values in a separate graph. Z data format: 0x00-0x0F-0x02-0x23= 0x0F<<16 | 0x02<<8 | 0x23 =1049123
  - If it is greater than 4 bytes, then it contains HR, HRV, and R-R values.

1. **ECG Data Format**: Identical to the format in [[OD - ECG Raw Data Commands#ECG Data Format]].
2. **HR and HRV Data Format**: 
   - First byte: HR (heart rate)
   - Second byte: HRV (heart rate variability)
   - Remaining bytes: R_R intervals (variable length, not fixed; each R_R value is two bytes)
   - Example: `0x00-0x39-0x00-0xa8-0x01-0x16-0x01-0x80-0x01-0xe3-0x02-0x4c-0x02-0xb9-0x03-0x1f-0x03-0x7f-0x03-0xe7`
   - `0x10`: HR
   - `0x14`: HRV
   - `0x00` to `0xe7`: R_R intervals

### Formula for R_R Calculation
The received R_R data is raw and requires conversion to real time intervals using:  
$TimeInterval_i = ((RR_{i+1} - RR_{i}) / 128) * 1000$  
- Units: milliseconds  
- Where:  
  - `RR_i`: Current R_R interval (raw byte value)  
  - `RR_{i+1}`: Next R_R interval (raw byte value)  
Example: ```10-14-2-20-43-6D-70-87-94-A0```
$0x20-0x2 = 32-2 = 30.$  
$(30/128)*1000 = 234.375ms$.

### Version
| Version | Author    | Published Date | Comments                     |
| ------- | --------- | -------------- | ---------------------------- |
| 1.0     | Karthik P | April  1, 2025 |                              |
| 1.1     | Karthik P | May  27, 2025  | Added Impedance data format  |




## UUIDs
The service and characteristic UUIDs for HRM_HRV are
`4e771a15-2665-cf92-9073-8c64a4ab357 = service UUID`
`48837cb0-b733-7c24-31b7-222222222222 = characteristic UUID`

## Commands:
- To get HRM and HRV data send `HRM_HRV`
- To stop HRM and HRV task send `STOPHRM_HRV`.

NOTE: After sending this command, wait 30 seconds to receive the data. Sometimes you may get single byte of data due to poor skin contact.

## How to interpret the received data:

- The first byte represents the error status and can range from **0x00 to 0x74**.
- If the **PPG signal is good**, the error byte will be **0x00**.
- If the **PPG signal is poor**, the error byte can be one of the following:
    - **0x01** → **POOR SKIN CONTACT**
	- **0x02** → **PPG NOT FOUND**
- [Update]With this error bytes you we receive just PPG data.
- If the signal quality is **moderate** (not too bad but insufficient for R-R detection), the error byte may have one of these values:
    - **0x14** → **OUT OF TOLERANCE**
    - **0x24** → **LOW PEAK COUNT**
    - **0x44** → **HIGH VARIANCE**	
- The first 384 bytes contain PPG data, ranging from byte 1 to byte 384.
    - Each PPG data point is 3 bytes long, creating 128 PPG samples from the first 385 bytes.
    - `EX: 0x21-0x12-0x23-0x20-0x09-0x21-0x21-0x1-0x4A-0x20-0x1C-0xD3-0x20-0xAB-0xCE-` For the first 3 bytes: the first byte's upper nibble contains a flag (in 0x21, 0x2 is the flag). The remaining bytes contain PPG data. To process: remove the flag and combine the remaining bytes into a single PPG sample. Repeat for all bytes up to byte 384.
- 0th byte will be error byte. 
- Byte 385 contains HR value. Unit Beats per minute. 
- 386 Byte contains RMSSD value[HRV]. Unit millisecond.
- The remaining bytes contain R-R data (variable length).
    - R-R data is 1 byte long.
    - R-R data conversion from BPM to milliseconds.$$  ms=(RR*0.04)/60  $$
    - apply this formula for all the R-R values and then plot this values.
    


### Version Table

| Version | Author    | Published Date | Comments                                    |
| ------- | --------- | -------------- | ------------------------------------------- |
| 1.0     | Karthik P | Feb 9, 2025    |                                             |
| 1.1     | Karthik P | Feb 14, 2025   | Added error bytes                           |
| 1.2     | karthik.P | Mar 3, 2025    | Byte correction                             |
| 1.3     | Karthik.P | Mar 7, 2025    | Formula for R-R, sending RMSSD value        |
| 1.4     | Karthik.P | Apr  10, 2025  | Sending error data also                     |
| 1.5     | Karthik.P | Apr 24, 2025   | Removed Low confidence from the error flags |


## UUIDs

The IMU task uses the following service and characteristic UUIDs:

- **Service UUID:** `4e771a15-2665-cf92-9073-8c64a4ab357`
- **Characteristic UUID:** `48837cb0-b733-7c24-31b7-222222222222`

## Commands
- **Start BMM:**  
	Send `STARTBMM:X1_X2_X3
	- `X1`: Power Mode   
	- `X2`: Output Date Rate  
	- `X3: Sample averaging

- **Stop BMM:**  
	Send `STOPBMM`
## Command parameters
#### X1 : Power Mode

| Power mode       | Byte value |
| ---------------- | ---------- |
| Suspend mode     | 0x00       |
| Normal mode      | 0x01       |
| UPD_OAE mode     | 0x02       |
| Forced mode      | 0x03       |
| Forced fast mode | 0x04       |
| FGR mode         | 0x05       |
| FGR fast mode    | 0x06       |
| BR mode          | 0x07       |
| BR fast mode     | 0x08       |

#### X2: Output data rate

| Data rate in Hz | Byte value |
| --------------- | ---------- |
| 400             | 0x02       |
| 200             | 0x03       |
| 100             | 0x04       |
| 50              | 0x05       |
| 25              | 0x06       |
| 12              | 0x07       |
| 6               | 0x08       |
| 3.125           | 0x09       |
| 1.5625          | 0x0A       |
|                 |            |
|                 |            |
#### X3: sample Averaging

| Sample average | Byte value |
| -------------- | ---------- |
| No average     | 0x00       |
| 2 samples      | 0x01       |
| 4 samples      | 0x02       |
| 8 samples      | 0x03       |

## Converting Received data into samples 
 - Data format: big endian
 - (4 bytes x-axis)-(4 bytes y-axis)-(4 bytes z-axis)
 - 2's compliment is needed before plotting.
 
 Example_sample:
- bytes: "0x01-0x23-0x42-0x22-0xA8-0xBC-0x08-0x89-0x03-0x53-0x7D-0x2F"
- first_4_bytes: "0x01-0x23-0x42-0x22"
- conversion: "0x01234222 = (0x01 << 24) | (0x23 << 16) | (0x42 << 8) | 0x22"
note: "This conversion is the same for all samples."


**Note:** Every time device only send 12 bytes in a packet.


### Version Table

| Version | Author    | Published Date | Comments |
| ------- | --------- | -------------- | -------- |
| 1.0     | Karthik P | Jan 15, 2026   |          |



### Commands:

- **`STARTACC:N_M`**: Starts the accelerometer data streaming, where `N` and `M` can be one of the following values:

|`N`|Description|
|---|---|
|`PD`|Power Down|
|`1`|1 Hz Low Power|
|`12_5`|12.5 Hz Low Power|
|`25`|25 Hz Low Power|
|`50`|50 Hz Low Power|
|`100`|100 Hz Low Power|
|`200`|200 Hz Low Power|
|`400`|400 Hz Low Power|
|`800`|800 Hz Low Power|

| `M`   | Description  |
| ----- | ------------ |
| `2G`  | ±2_g range_  |
| `4G`  | ±4_g range_  |
| `8G`  | ±8_g range_  |
| `16G` | ±16_g range_ |

**Example:**

To start the accelerometer at 12.5 Hz with ±4_g_ range, send:

`STARTACC:12_5_4G`

To start at 200 Hz with ±16_g_ range, send:

`STARTACC:200_16G`

**`STOPACC`**: Stops the accelerometer data streaming.

---

### Structure of Accelerometer Data Packet:

The accelerometer data is structured as follows:

```
0xEO-CO-FF-40-00-CO-EO-CO-00-80-00-CO-DF-CO-FF-40-00-40-EO-CO-FF-C0-00-CO-...

```

- **Data Format**:
    - Each packet consists of alternating 2-byte values for the X, Y, and Z axes.
    - The sequence continues as follows:
        - **First 2 bytes**: X-axis data
        - **Next 2 bytes**: Y-axis data
        - **Next 2 bytes**: Z-axis data
        - This pattern repeats for the duration of the data packet.
- **Packet Size**:
    - The total packet size can vary and may consist of multiple 360 bytes packets.
    - Any remaining data in the FIFO buffer is included in the final packet.

### Additional Considerations:

- All received data will be raw values corresponding to the X, Y, and Z axes of acceleration.
- Ensure that the receiving end is prepared to handle the size and structure of incoming packets, including any necessary parsing for the X, Y, and Z data.
- Consider adding error handling or validation mechanisms to manage any discrepancies in the expected data format or packet sizes.

---

### Converting Accelerometer Raw Data to Resolved X, Y, Z Axis Data

To convert the accelerometer raw data into resolved X, Y, and Z axis data (in meaningful units)mg:

1. **Little Endian to Big Endian Conversion**:
    
    1. Received data will be in little-endian format.
    2. Conversion Example: 0xA3E2 (little-endian) → 0xE2A3 (big-endian), then proceed to the next steps.
2. **2’s Complement Conversion**:
    
    1. Convert each raw 16-bit value (2 bytes) for the X, Y, and Z axes to a signed integer.
    2. This conversion handles the 2's complement representation of the raw data.
3. **Multiply by Scale Factor**:
    
    - Use the appropriate scaling factor based on your selected range:
        
        |Range|Scaling Factor|
        |---|---|
        |2G|0.061|
        |4G|0.122|
        |8G|0.244|
        |16G|0.488|
        

- Multiply each resolved signed integer by the corresponding scaling factor to convert the values to g-force or m/s².

NOTE: Default G scaling is 4G.

### Version Table

| Version | Author    | Published Date | Comments                                                                          |
| ------- | --------- | -------------- | --------------------------------------------------------------------------------- |
| 1.0     | Karthik P | Oct 28, 2024   |                                                                                   |
| 1.1     | Karthik P | Nov 20, 2024   | MTU size is reduced to 360 bytes from 450 bytes.                                  |
| 1.2     | Karthik P | Jan 10, 2025   | Configurable G range                                                              |
| 1.3     | Karthik P | Jan 20 2025    | Fixed the bug in the code and added little-endian format conversion for raw data. |




## UUID
The service and characteristic UUIDs for HR and HRV are

`a0262760-08c2-11e1-9073-0e8ac72e1234 = service UUID`
`a0262760-08c2-11e1-9073-0e8ac72e0001 = characteristic UUID`




Types of data available in this feature:
- SigMot
- Step count
- Temperature
- Heart rate 

##### Command to get data:

`GETVITALS`: This command returns all of the above data in the specified format.

#### Data format for received data
- First data frame will be the 4 byte data which will gives the number of frame are stored in the flash.
- |-SigMot frame size byte-|-Steps frame size byte-|-Temperature  frame size byte -|-Heart rate frame size byte-|
- In the frame size data does not include the frame in the buffer. So sometimes use will receive one extra frame which is less than 60.
- A single notification chunk can be up to 60 bytes.
- A chunk smaller than 60 bytes indicates the last chunk for that data packet.
- All data types listed above are sent in one or more chunks.

Example:
```
1: [2,2,2,2]
2: [0, 0, 0, 32, 0, 0, 0, 32, 32, 0, 32, 32, 0, 0, 0, 0, 32, 0, 32, 32, 0, 0, 32, 32, 69, 32, 69, 69, 32, 32, 32, 69, 69, 32, 69, 32, 32, 69, 69, 69, 69, 32, 32, 69, 32, 32, 69, 32, 69, 69, 69, 32, 32, 32, 32, 0, 32, 0, 0, 0]
3:[0, 0, 0, 32, 0, 0, 0, 32, 32, 0, 32, 32, 0, 0, 0, 0, 32, 0, 32, 32, 0, 0, 32, 32, 69, 32, 69, 69, 32, 32, 32, 69, 69, 32, 69, 32, 32, 69, 69, 69, 69, 32, 32, 69, 32, 32, 69, 32, 69, 69, 69, 32, 32, 32, 32, 0, 32, 0, 0, 0]
4: [0, 0, 0, 0, 0, 0, 0, 0, 0, 109, 67]
```

In the above example, the first array is the frame count of the data. The second array is the 60-byte SIGMOT chunk and the third array is the remaining data in the buffer.

#### Data conversion
- SigMot:
	- Each byte in a chunk represents a single SigMot value.
	- Example: 0x23-0x34-0x45 — 0x23 is one SigMot value.
- Steps:
	- Same format as SigMot: each byte is one step-related data value.
- Temperature:
	- Each byte represents a temperature data value. To compute the real temperature (°C) use:
		(byte + 200) / 10 = temperature in °C
	- Example: (23 + 200) / 10 = 22.3 °C
- Heart Rate:
	- Same format as SigMot: each byte is one heart-rate value.


After sending a command wait for up to 30s to receive the data. The data may not always be immediately available based on the tasks schedules on the device 



## Heart Rate Error Codes




### Version Table

| Version | Author    | Published Date | Comments |
| ------- | --------- | -------------- | -------- |
| 1.0     | Karthik P | Mar 07, 2025   |          |






## UUIDs

The IMU task uses the following UUIDs:

- Service UUID: `4e771a15-2665-cf92-9073-8c64a4ab357`  
- Characteristic UUID: `48837cb0-b733-7c24-31b7-222222222222`

## Commands

- `STARTVITALSTX` — Starts the data transfer.  
	- There is no explicit stop command; the transfer ends when the device has sent all available data or the buffer is emptied.

## Data format

- The first frame is a 4-byte metadata field that indicates the total payload length in bytes (unsigned 32-bit integer; byte order per device implementation).
- Subsequent frames are up to 256 bytes each.
- Each frame is composed of 8-byte subframes. Subframe layout (bytes shown in order):

	|HR_peak - HR_fft | Sigmot_hi - Sigmot_lo | Step_hi - Step_lo | Temp_hi - Temp_lo |

	- Example subframe bytes: `0x23 0x24 0x01 0x20 0x23 0x34 0x00 0x00`

- Field details:
	- Heart rate (2 bytes)
		- First byte: peak-based heart rate
		- Second byte: FFT-based heart rate
		- If the device cannot compute a value, these bytes contain an error code (see device error table).
	- Sigmot (2 bytes)
		- Combine the two bytes to form the value: value = (high_byte << 8) | low_byte
		- Example: `0x01 0x02` -> `0x01 << 8 | 0x02`
	- Step count (2 bytes)
		- Same combination method as Sigmot.
	- Temperature (2 bytes)
		- Reserved for future use.

- The final transmitted frame may be shorter than 256 bytes; a shorter final frame indicates the end of the payload.
#### Error table

When an error code is present in the heart-rate bytes, treat the measurement as invalid and apply the suggested remediation below.

| Error Code | Error name        | Description                             | Suggested action                      |
| ---------- | ----------------- | --------------------------------------- | ------------------------------------- |
| `0x01`     | POOR_SKIN_CONTACT | Sensor contact with skin is inadequate  | Re-seat device, clean sensor, retry   |
| `0x02`     | PPG_NOT_FOUND     | No PPG signal detected                  | Reduce ambient light, check placement |
| `0x03`     | NOT_WORN          | Device not being worn or loose          | Ensure device is worn correctly       |
| `0x04`     | OUT_OF_TOLERANCE  | Measured value outside expected range   | Recalibrate or retry measurement      |
| `0x04`     | LESS_PEAKS        | Insufficient peaks for reliable HR      | Ask user to remain still and retry    |
| `0x04`     | HIGH_VARIANCE     | High variability in signal/measurements | Stabilize sensor position and retry   |

Notes:
- Reported errors apply per-sample; do not use values when an error code appears.
- Codes are single-byte values encoded in the heart-rate fields.

### Version Table

| Version | Author    | Published Date | Comments |
| ------- | --------- | -------------- | -------- |
| 1.0     | Karthik P | Jan 21, 2026   |          |


## UUID
The service and characteristic UUIDs for HR and HRV are

`a0262760-08c2-11e1-9073-0e8ac72e1234 = service UUID`
`a0262760-08c2-11e1-9073-0e8ac72e0001 = characteristic UUID`

## Commands:
- To get HR data send `get_hr
- To get HRV data send `get_hrv`
- To change the refresh rate task `ref_hr:N`

> Interval between the data depends on the refresh rate of the task that can be changed by sending the command `hr_ref:N` where N is an integer number which represents number of seconds.
- Example : if N=300 then the task will repeats every 5 minutes $$duration= N/60$$
## Received Data:

After sending the command, you'll receive an array of numbers.

Example for HR: [80,82,84,0,0,0,0,0,81,83,85] — The first number (80) shows heart rate detected in the first 300 seconds or 5 minute, the second number (82) shows heart rate in the next 300 seconds, and so on. Zeros is due to less confidence. 
Same goes for HRV data.

### Version Table

| Version | Author    | Published Date | Comments |
| ------- | --------- | -------------- | -------- |
| 1.0     | Karthik P | Mar 07, 2025   |          |




