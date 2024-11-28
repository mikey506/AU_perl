# AU_perl - Artificial Unintelligence

# Dataset Processing and Preprocessing Pipeline in Perl

This project provides a robust Perl-based pipeline for handling, preprocessing, and analyzing datasets. The primary focus is on textual data, with built-in capabilities to process large-scale datasets efficiently.

---

## **Features**
1. **Load and Inspect Datasets**
   - Load structured data from CSV files.
   - Inspect metadata, such as column names and record counts.
   - Preview the dataset before and after preprocessing.

2. **Data Preprocessing**
   - Handles missing or empty fields in the dataset.
   - Trims unnecessary whitespace from text fields.
   - Computes additional metadata, such as message length.

3. **Error Handling**
   - Validates the input file's existence and structure.
   - Catches and reports errors during data loading and preprocessing.

4. **Performance Monitoring**
   - Tracks and reports the time taken for various operations.
   - Efficiently handles datasets with millions of records.

5. **Debugging**
   - Provides detailed debug logs to trace operations and detect issues.

---

## **Requirements**

### **Perl Version**
- Perl 5.10 or later

### **Dependencies**
Install the required Perl modules using `cpan`:
```bash
cpan Text::CSV
cpan Getopt::Long
cpan Time::HiRes
cpan Encode

perl test_dataset.pl --csv_file=cleaned_messages.csv
