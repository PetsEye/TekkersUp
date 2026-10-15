import { useState } from 'react';
import { WelcomeScreen } from './Welcome';
import { AuthForm } from './AuthForm';
import { OnboardingScreen } from './Onboarding';

type Step = 'welcome' | 'login' | 'register' | 'about' | 'onboarding';

interface Props {
  onAuthed: (email: string) => void;
}

export function AuthFlow({ onAuthed }: Props) {
  const [step, setStep] = useState<Step>('welcome');
  const [newEmail, setNewEmail] = useState('');

  if (step === 'welcome') {
    return (
      <WelcomeScreen
        onLogin={() => setStep('login')}
        onRegister={() => setStep('register')}
        onAbout={() => setStep('about')}
      />
    );
  }
  if (step === 'about') {
    return (
      <OnboardingScreen primaryLabel="Create an account" onPrimary={() => setStep('register')} onBack={() => setStep('welcome')} />
    );
  }
  if (step === 'onboarding') {
    return <OnboardingScreen primaryLabel="Get started" onPrimary={() => onAuthed(newEmail)} />;
  }
  return (
    <AuthForm
      mode={step}
      onSwitch={setStep}
      onBack={() => setStep('welcome')}
      onDone={(email) => {
        if (step === 'register') {
          setNewEmail(email);
          setStep('onboarding');
        } else {
          onAuthed(email);
        }
      }}
    />
  );
}
