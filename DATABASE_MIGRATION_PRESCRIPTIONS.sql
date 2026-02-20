-- Prescriptions Management System Migration
-- Date: 2026-02-20

-- Update prescriptions table with new fields
ALTER TABLE prescriptions 
  ADD COLUMN IF NOT EXISTS vet_id UUID NOT NULL REFERENCES vets(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS duration INT,
  ADD COLUMN IF NOT EXISTS instructions TEXT,
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('active', 'pending', 'expired', 'completed', 'discontinued')),
  ADD COLUMN IF NOT EXISTS refills_used INT DEFAULT 0,
  MODIFY COLUMN prescribed_by VARCHAR(255),
  DROP CONSTRAINT IF EXISTS prescriptions_prescribed_by_fkey;

-- Create prescriptions table if it doesn't exist
CREATE TABLE IF NOT EXISTS prescriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
  vet_id UUID REFERENCES vets(id) ON DELETE SET NULL,
  medication VARCHAR(255) NOT NULL,
  dosage VARCHAR(255) NOT NULL,
  frequency VARCHAR(255) NOT NULL,
  duration INT,
  start_date DATE NOT NULL,
  end_date DATE,
  instructions TEXT,
  pharmacy_info VARCHAR(255),
  refills_remaining INT DEFAULT 0,
  refills_used INT DEFAULT 0,
  notes TEXT,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('active', 'pending', 'expired', 'completed', 'discontinued')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create medications table
CREATE TABLE IF NOT EXISTS medications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) UNIQUE NOT NULL,
  generic_name VARCHAR(255) UNIQUE NOT NULL,
  brand_names TEXT,
  type VARCHAR(50) DEFAULT 'other' CHECK (type IN (
    'antibiotic', 'pain_relief', 'anti_inflammatory', 'antifungal',
    'antihistamine', 'antidiarrheal', 'antiemetic', 'cardiac',
    'dermatological', 'endocrine', 'gastrointestinal', 'respiratory',
    'neurological', 'ophthalmic', 'topical', 'other'
  )),
  active_ingredient TEXT NOT NULL,
  description TEXT,
  side_effects TEXT,
  contraindications TEXT,
  warnings TEXT,
  precautions TEXT,
  dosage_units VARCHAR(100),
  typical_dosage_range VARCHAR(255),
  max_daily_dose VARCHAR(100),
  pet_specific_info TEXT,
  food_interactions VARCHAR(255),
  is_active BOOLEAN DEFAULT true,
  manufacturer VARCHAR(255),
  storage_instructions TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create drug_interactions table
CREATE TABLE IF NOT EXISTS drug_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  medication_id_1 UUID NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
  medication_id_2 UUID NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
  severity VARCHAR(50) DEFAULT 'moderate' CHECK (severity IN ('mild', 'moderate', 'severe', 'contraindicated')),
  description TEXT NOT NULL,
  mechanism TEXT,
  management_strategies TEXT,
  symptoms TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(medication_id_1, medication_id_2),
  CONSTRAINT different_medications CHECK (medication_id_1 != medication_id_2)
);

-- Create prescription_refills table
CREATE TABLE IF NOT EXISTS prescription_refills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prescription_id UUID NOT NULL REFERENCES prescriptions(id) ON DELETE CASCADE,
  refill_date DATE NOT NULL,
  expiration_date DATE,
  quantity INT NOT NULL,
  pharmacy_name VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_prescriptions_pet_id ON prescriptions(pet_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_vet_id ON prescriptions(vet_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_status ON prescriptions(status);
CREATE INDEX IF NOT EXISTS idx_prescriptions_start_date ON prescriptions(start_date);
CREATE INDEX IF NOT EXISTS idx_prescriptions_end_date ON prescriptions(end_date);
CREATE INDEX IF NOT EXISTS idx_medication_name ON medications(name);
CREATE INDEX IF NOT EXISTS idx_medication_generic_name ON medications(generic_name);
CREATE INDEX IF NOT EXISTS idx_drug_interactions_med1 ON drug_interactions(medication_id_1);
CREATE INDEX IF NOT EXISTS idx_drug_interactions_med2 ON drug_interactions(medication_id_2);
CREATE INDEX IF NOT EXISTS idx_prescription_refills_prescription_id ON prescription_refills(prescription_id);
CREATE INDEX IF NOT EXISTS idx_prescription_refills_refill_date ON prescription_refills(refill_date);

-- Insert sample medications into the medications table (optional)
INSERT INTO medications (name, generic_name, type, active_ingredient, description, side_effects, contraindications, warnings, typical_dosage_range, is_active)
VALUES
  ('Amoxicillin', 'amoxicillin', 'antibiotic', 'amoxicillin trihydrate', 'Beta-lactam antibiotic', 'Diarrhea, vomiting, allergic reactions', 'Penicillin allergy', 'May reduce effectiveness of oral contraceptives', '20-40 mg/kg', true),
  ('Carprofen (Rimadyl)', 'carprofen', 'pain_relief', 'carprofen', 'NSAID for pain and inflammation', 'GI upset, liver/kidney issues', 'History of GI ulcers, kidney disease', 'Monitor for signs of GI bleeding', '2-4 mg/kg', true),
  ('Meloxicam (Metacam)', 'meloxicam', 'pain_relief', 'meloxicam', 'NSAID for pain management', 'GI upset, kidney problems', 'Kidney disease, GI ulcers', 'Use lowest effective dose', '0.1-0.2 mg/kg', true),
  ('Tramadol', 'tramadol', 'pain_relief', 'tramadol hydrochloride', 'Opioid analgesic', 'Drowsiness, constipation, nausea', 'Severe respiratory disease', 'May cause sedation', '5-10 mg/kg', true),
  ('Gabapentin', 'gabapentin', 'pain_relief', 'gabapentin', 'Nerve pain relief', 'Drowsiness, ataxia', 'Renal impairment', 'Gradually taper when discontinuing', '10-30 mg/kg', true),
  ('Prednisone', 'prednisone', 'anti_inflammatory', 'prednisone', 'Corticosteroid', 'Increased appetite, thirst, urination', 'Active infections, diabetes', 'Long-term use may cause complications', '0.5-2 mg/kg', true),
  ('Doxycycline', 'doxycycline', 'antibiotic', 'doxycycline hyclate', 'Broad-spectrum antibiotic', 'GI upset, photosensitivity', 'Tetracycline allergy', 'Give with food, avoid dairy products', '5-10 mg/kg', true),
  ('Fluconazole', 'fluconazole', 'antifungal', 'fluconazole', 'Antifungal medication', 'Nausea, vomiting, GI upset', 'Hepatic impairment', 'Monitor liver function', '5-10 mg/kg', true),
  ('Diphenhydramine', 'diphenhydramine', 'antihistamine', 'diphenhydramine hydrochloride', 'First-generation antihistamine', 'Drowsiness, dry mouth', 'Closed-angle glaucoma', 'May cause sedation', '2-4 mg/kg', true),
  ('Omeprazole', 'omeprazole', 'gastrointestinal', 'omeprazole', 'Proton pump inhibitor', 'Headache, GI upset', 'Severe liver disease', 'Reduce other medication absorption', '0.5-1 mg/kg', true);

-- Add comments to tables for documentation
COMMENT ON TABLE prescriptions IS 'Stores pet medication prescriptions with refill tracking';
COMMENT ON TABLE medications IS 'Medication database with dosing, interactions, and side effects';
COMMENT ON TABLE drug_interactions IS 'Tracks known drug interactions and their severity';
COMMENT ON TABLE prescription_refills IS 'Records refill history for each prescription';

COMMENT ON COLUMN prescriptions.status IS 'Prescription status: active, pending, expired, completed, or discontinued';
COMMENT ON COLUMN medications.type IS 'Category of medication for classification';
COMMENT ON COLUMN drug_interactions.severity IS 'Interaction severity level for warnings';
