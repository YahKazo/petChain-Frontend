# Pet Prescriptions - Quick Start Guide

## Getting Started

The Pet Prescriptions Management System is now ready to use. Here are practical examples to get started.

## Prerequisites

1. Database migration applied:
   ```bash
   psql -U username -d database_name -f DATABASE_MIGRATION_PRESCRIPTIONS.sql
   ```

2. Backend running:
   ```bash
   npm start
   ```

## Quick Examples

### 1. Create a Prescription for Antibiotics

```bash
curl -X POST http://localhost:3000/prescriptions \
  -H "Content-Type: application/json" \
  -d '{
    "petId": "550e8400-e29b-41d4-a716-446655440000",
    "vetId": "660e8400-e29b-41d4-a716-446655440000",
    "medication": "Amoxicillin",
    "dosage": "250mg",
    "frequency": "Every 8 hours (3x daily)",
    "duration": 14,
    "startDate": "2026-02-20",
    "instructions": "Take with food. Complete full course even if feeling better.",
    "refillsRemaining": 0,
    "notes": "For bacterial ear infection"
  }'
```

**Response:**
```json
{
  "id": "770e8400-e29b-41d4-a716-446655440001",
  "petId": "550e8400-e29b-41d4-a716-446655440000",
  "vetId": "660e8400-e29b-41d4-a716-446655440000",
  "medication": "Amoxicillin",
  "dosage": "250mg",
  "frequency": "Every 8 hours (3x daily)",
  "duration": 14,
  "startDate": "2026-02-20T00:00:00Z",
  "endDate": "2026-03-06T00:00:00Z",
  "status": "pending",
  "refillsRemaining": 0,
  "refillsUsed": 0,
  "createdAt": "2026-02-20T10:30:00Z"
}
```

### 2. Calculate Dosage for Pain Relief

```bash
curl -X POST http://localhost:3000/prescriptions/calculate-dosage/validate \
  -H "Content-Type: application/json" \
  -d '{
    "medicationName": "Carprofen",
    "petWeight": 25,
    "weightUnit": "kg",
    "age": 5
  }'
```

**Response:**
```json
{
  "dosage": 100,
  "unit": "mg",
  "frequency": "Every 12 hours (2x daily)",
  "warnings": []
}
```

### 3. Check Drug Interactions

```bash
curl -X POST http://localhost:3000/prescriptions/check-interactions \
  -H "Content-Type: application/json" \
  -d '{
    "medicationNames": ["Amoxicillin", "Carprofen"]
  }'
```

**Response:**
```json
{
  "interactions": [
    {
      "medication1": "Amoxicillin",
      "medication2": "Carprofen",
      "severity": "moderate",
      "description": "NSAIDs may increase amoxicillin levels",
      "mechanism": "Reduced renal clearance",
      "managementStrategies": "Monitor for side effects; adjust dose if needed",
      "symptoms": "GI upset, diarrhea, increased amoxicillin levels"
    }
  ],
  "severeWarnings": [],
  "allClear": false
}
```

### 4. Get Active Prescriptions for a Pet

```bash
curl http://localhost:3000/prescriptions/pet/550e8400-e29b-41d4-a716-446655440000/active
```

**Response:**
```json
[
  {
    "id": "770e8400-e29b-41d4-a716-446655440001",
    "medication": "Carprofen",
    "dosage": "100mg",
    "frequency": "Every 12 hours (2x daily)",
    "startDate": "2026-02-15T00:00:00Z",
    "endDate": "2026-02-28T00:00:00Z",
    "status": "active",
    "refillsRemaining": 2,
    "refillsUsed": 0
  }
]
```

### 5. Set Up Refill Reminders

```bash
curl http://localhost:3000/prescriptions/reminders?days=7
```

**Response:**
```json
[
  {
    "prescriptionId": "770e8400-e29b-41d4-a716-446655440001",
    "medication": "Carprofen",
    "frequency": "Every 12 hours (2x daily)",
    "refillsRemaining": 2,
    "daysUntilRefill": 3,
    "estimatedRefillDate": "2026-02-23T00:00:00Z",
    "petName": "Max",
    "petId": "550e8400-e29b-41d4-a716-446655440000"
  }
]
```

### 6. Record a Refill

```bash
curl -X POST http://localhost:3000/prescriptions/770e8400-e29b-41d4-a716-446655440001/record-refill \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 30,
    "pharmacyName": "PetCare Pharmacy Downtown"
  }'
```

**Response:**
```json
{
  "id": "880e8400-e29b-41d4-a716-446655440002",
  "prescriptionId": "770e8400-e29b-41d4-a716-446655440001",
  "refillDate": "2026-02-23T10:45:00Z",
  "expirationDate": "2026-03-25T00:00:00Z",
  "quantity": 30,
  "pharmacyName": "PetCare Pharmacy Downtown",
  "createdAt": "2026-02-23T10:45:00Z"
}
```

### 7. Add a New Medication to Database

```bash
curl -X POST http://localhost:3000/medications \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Cephalexin",
    "genericName": "cephalexin",
    "type": "antibiotic",
    "activeIngredient": "cephalexin monohydrate",
    "description": "Beta-lactam antibiotic for bacterial infections",
    "sideEffects": "GI upset, allergic reactions, yeast infections",
    "contraindications": "Penicillin allergy",
    "warnings": "Monitor for allergic reactions",
    "typicalDosageRange": "25-40 mg/kg",
    "dosageUnits": "mg",
    "foodInteractions": "Can be taken with or without food"
  }'
```

### 8. Get Prescription History

```bash
curl http://localhost:3000/prescriptions/pet/550e8400-e29b-41d4-a716-446655440000/history
```

**Response:**
```json
[
  {
    "id": "770e8400-e29b-41d4-a716-446655440001",
    "medication": "Amoxicillin",
    "dosage": "250mg",
    "frequency": "Every 8 hours (3x daily)",
    "startDate": "2026-02-20T00:00:00Z",
    "endDate": "2026-03-06T00:00:00Z",
    "status": "active",
    "refillsRemaining": 0,
    "refillsUsed": 0,
    "createdAt": "2026-02-20T10:30:00Z"
  },
  {
    "id": "990e8400-e29b-41d4-a716-446655440003",
    "medication": "Carprofen",
    "dosage": "100mg",
    "frequency": "Every 12 hours (2x daily)",
    "startDate": "2026-01-15T00:00:00Z",
    "endDate": "2026-01-29T00:00:00Z",
    "status": "completed",
    "refillsRemaining": 0,
    "refillsUsed": 3,
    "createdAt": "2026-01-15T14:20:00Z"
  }
]
```

### 9. Get Expiring Prescriptions

```bash
curl http://localhost:3000/prescriptions/pet/550e8400-e29b-41d4-a716-446655440000/expiring-soon?days=30
```

**Response:**
```json
[
  {
    "id": "770e8400-e29b-41d4-a716-446655440001",
    "medication": "Carprofen",
    "startDate": "2026-02-15T00:00:00Z",
    "endDate": "2026-02-28T00:00:00Z",
    "status": "active"
  }
]
```

### 10. Discontinue a Prescription

```bash
curl -X PATCH http://localhost:3000/prescriptions/770e8400-e29b-41d4-a716-446655440001/discontinue \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Owner request - pet doing better"
  }'
```

## Working with Medications

### Search for Medications

```bash
curl "http://localhost:3000/medications/search?query=amox"
```

### Get Medications by Type

```bash
# Get all antibiotics
curl http://localhost:3000/medications/type/antibiotic

# Get all pain relief medications
curl http://localhost:3000/medications/type/pain_relief
```

### Get All Medication Types

```bash
curl http://localhost:3000/medications/types
```

### Deactivate a Medication

```bash
curl -X PATCH http://localhost:3000/medications/770e8400-e29b-41d4-a716-446655440001/deactivate
```

## Common Workflow

### Step 1: Verify Dosage
```bash
# Calculate correct dosage for pet's weight
curl -X POST http://localhost:3000/prescriptions/calculate-dosage/validate \
  -H "Content-Type: application/json" \
  -d '{
    "medicationName": "Amoxicillin",
    "petWeight": 25,
    "weightUnit": "kg"
  }'
```

### Step 2: Check Interactions
```bash
# Make sure medication doesn't interact with others
curl -X POST http://localhost:3000/prescriptions/check-interactions \
  -H "Content-Type: application/json" \
  -d '{
    "medicationNames": ["Amoxicillin", "Carprofen"]
  }'
```

### Step 3: Create Prescription
```bash
# Once verified, create the prescription
curl -X POST http://localhost:3000/prescriptions \
  -H "Content-Type: application/json" \
  -d '{
    "petId": "550e8400-e29b-41d4-a716-446655440000",
    "vetId": "660e8400-e29b-41d4-a716-446655440000",
    "medication": "Amoxicillin",
    "dosage": "250mg",
    "frequency": "Every 8 hours (3x daily)",
    "duration": 14,
    "startDate": "2026-02-20",
    "refillsRemaining": 0
  }'
```

### Step 4: Monitor Refills
```bash
# Check for upcoming refills
curl http://localhost:3000/prescriptions/reminders?days=7
```

### Step 5: Record Refills
```bash
# When filled, record it
curl -X POST http://localhost:3000/prescriptions/770e8400-e29b-41d4-a716-446655440001/record-refill \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 30,
    "pharmacyName": "PetCare Pharmacy"
  }'
```

## Status Reference

- **pending**: Prescription created, not yet started
- **active**: Currently in effect
- **expired**: End date has passed
- **completed**: All refills used
- **discontinued**: Stopped by veterinarian

## Interaction Severity Levels

- **mild**: Minor interaction, monitor
- **moderate**: Consider management strategies
- **severe**: Significant precautions needed
- **contraindicated**: Should not be used together

## Pre-loaded Medications

The system comes with these medications ready to use:
- Amoxicillin
- Carprofen (Rimadyl)
- Meloxicam (Metacam)
- Tramadol
- Gabapentin
- Prednisone
- Doxycycline
- Fluconazole
- Diphenhydramine
- Omeprazole

## Troubleshooting

### "No refills remaining" error
- This medication has no refills left
- Create a new prescription or request authorization for more refills

### Dosage validation warnings
- Always verify dosages with veterinarian
- Age and weight matter - adjust accordingly
- Watch for special considerations (kidney disease, etc.)

### Drug interaction not found
- Not all interactions are in the database
- Always consult with veterinarian
- New interactions can be added via API

## Best Practices

1. **Always verify with vet** - Calculations are guidance only
2. **Check interactions first** - Before prescribing multiple medications
3. **Track refills** - Record each refill to maintain accuracy
4. **Set refill reminders** - Never run out unexpectedly
5. **Monitor pet** - Watch for side effects and adverse reactions
6. **Update instructions** - Provide clear medication directions
7. **Keep history** - Maintain complete prescription records

## Support

For detailed API documentation, see: `PRESCRIPTIONS_API.md`
For module overview, see: `README.md` in prescriptions folder
For implementation details, see: `PRESCRIPTIONS_IMPLEMENTATION_SUMMARY.md`
