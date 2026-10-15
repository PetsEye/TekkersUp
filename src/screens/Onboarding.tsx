interface Props {
  primaryLabel: string;
  onPrimary: () => void;
  onBack?: () => void;
}

export function OnboardingScreen({ primaryLabel, onPrimary, onBack }: Props) {
  return (
    <div className="onboard">
      {onBack && (
        <button type="button" className="btn ghost small back" onClick={onBack}>
          ← Back
        </button>
      )}
      <div className="brand">TEKKERSUP</div>
      <span className="eyebrow accent-text">Onboarding / Read first</span>
      <h1 className="onboard-title">
        Train smarter,
        <br />
        one rep at a time
      </h1>
      <p className="lead">
        TEKKERSUP is a training companion for soccer players. Prop up your phone, run a drill, and get a clear read on
        your technique, along with specific things to work on before your next session.
      </p>

      <section>
        <h3>What the app does</h3>
        <p>
          Choose a drill, such as the Power Shot or the Inside-Foot Pass, and place your phone two to three metres away
          at waist height. TEKKERSUP follows your body through the camera and draws a live skeleton over your image, so
          you can see exactly what the app is tracking while you train.
        </p>
      </section>

      <section>
        <h3>What it measures</h3>
        <p>
          For each drill, the app tracks the angles that matter most for that technique. For a power shot, that means how
          far your kicking knee bends as you load the leg, how firmly your plant knee holds at contact, how upright your
          torso stays, and how your arms balance the swing. Every measurement is compared against target ranges written
          for that drill.
        </p>
      </section>

      <section>
        <h3>How reps are counted</h3>
        <p>
          Each strike is one rep. The app watches for your kicking leg to load back and then follow through, and it scores
          every rep on how many of its measurements landed inside the target range. You do not need to press anything
          between strikes. Start the set, train, and end it when you are done.
        </p>
      </section>

      <section>
        <h3>What you get back</h3>
        <p>
          When a set ends, you receive a report with an overall score, the average value for each measurement, the share
          of reps that were in range, and a score for every rep. Where a measurement is often out of range, the report
          gives you a plain pointer on what to change, such as opening your hips or bringing your heel back further.
          Every session is saved to your log so you can see your progress over time.
        </p>
      </section>

      <section>
        <h3>Before your first set</h3>
        <ul>
          <li>Film from the side so your kicking leg is clearly visible.</li>
          <li>Keep your whole body in frame, from head to feet.</li>
          <li>Train in good light and avoid standing with a bright window behind you.</li>
          <li>Use a warm-up first, so your first reps are not your strongest.</li>
        </ul>
      </section>

      <section>
        <h3>About your data</h3>
        <p>
          Video from your camera is analysed on your device. Your sessions and account are saved in this browser for now,
          so they stay on the device you trained on. Measurements come from a single camera, which makes them estimates.
          Treat the pointers as coaching guidance and not as a medical assessment.
        </p>
      </section>

      <button type="button" className="btn primary block onboard-cta" onClick={onPrimary}>
        {primaryLabel}
      </button>
    </div>
  );
}
