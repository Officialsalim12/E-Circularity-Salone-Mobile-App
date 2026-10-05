// Brevo sends the code and the welcome note. The code itself is never logged.
export type VerificationPurpose =
  | 'phone_registration'
  | 'email_registration'
  | 'password_reset';

export type VerificationMessage = {
  channel: 'email' | 'sms';
  destination: string;
  code: string;
  purpose: VerificationPurpose;
};

export type BrevoConfig = {
  apiKey: string;
  senderEmail: string;
  senderName: string;
  smsSender: string | null;
};

export type WelcomeMessage = {
  fullName: string;
  email: string | null;
  phone: string | null;
};

export interface VerificationDelivery {
  send(message: VerificationMessage): Promise<void>;
  sendWelcome(welcome: WelcomeMessage): Promise<void>;
}

export class VerificationDeliveryError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'VerificationDeliveryError';
  }
}

export class UnconfiguredVerificationDelivery implements VerificationDelivery {
  async send(message: VerificationMessage): Promise<void> {
    throw new VerificationDeliveryError(
      message.channel === 'sms' ? "Texts aren't set up." : "Email isn't set up.",
    );
  }

  async sendWelcome(): Promise<void> {
    throw new VerificationDeliveryError("Email isn't set up.");
  }
}

export class BrevoDelivery implements VerificationDelivery {
  constructor(private readonly brevo: BrevoConfig) {}

  async send(message: VerificationMessage): Promise<void> {
    const response =
      message.channel === 'sms' ? await this.sendSms(message) : await this.sendEmail(message);

    if (!response.ok) {
      throw new VerificationDeliveryError(
        message.channel === 'sms'
          ? "We couldn't send the text. Try again."
          : "We couldn't send the email. Try again.",
      );
    }
  }

  async sendWelcome(welcome: WelcomeMessage): Promise<void> {
    if (welcome.email) {
      const response = await this.postEmail({
        to: [{ email: welcome.email, name: welcome.fullName }],
        subject: 'Welcome to Circular Salone',
        textContent: `Hi ${welcome.fullName}, welcome to Circular Salone. Your account is ready. Sign in with this email whenever you like.`,
      });
      if (!response.ok) {
        throw new VerificationDeliveryError("We couldn't send the welcome email.");
      }
    }
    if (welcome.phone) {
      const response = await this.postSms(
        welcome.phone,
        `Hi ${welcome.fullName}, welcome to Circular Salone. Your account is ready. Sign in with this number.`,
      );
      if (!response.ok) {
        throw new VerificationDeliveryError("We couldn't send the welcome text.");
      }
    }
  }

  private sendEmail(message: VerificationMessage): Promise<Response> {
    const resetting = message.purpose === 'password_reset';
    return this.postEmail({
      to: [{ email: message.destination }],
      subject: resetting
        ? 'Reset your Circular Salone password'
        : 'Your Circular Salone code',
      textContent: resetting
        ? `Hi, use ${message.code} to reset your Circular Salone password. It expires in 10 minutes. If you didn't ask for this, you can ignore this email.`
        : `Hi, your Circular Salone code is ${message.code}. It expires in 10 minutes. If you didn't ask for this, you can ignore this email.`,
    });
  }

  private sendSms(message: VerificationMessage): Promise<Response> {
    const resetting = message.purpose === 'password_reset';
    const content = resetting
      ? `Circular Salone: use ${message.code} to reset your password. It expires in 10 minutes.`
      : `Circular Salone: your code is ${message.code}. It expires in 10 minutes.`;
    return this.postSms(message.destination, content);
  }

  private postEmail(body: {
    to: { email: string; name?: string }[];
    subject: string;
    textContent: string;
  }): Promise<Response> {
    return fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: this.headers(),
      body: JSON.stringify({
        sender: {
          name: this.brevo.senderName,
          email: this.brevo.senderEmail,
        },
        ...body,
      }),
    });
  }

  private postSms(destination: string, content: string): Promise<Response> {
    if (!this.brevo.smsSender) {
      return Promise.reject(
        new VerificationDeliveryError(
          "Texts aren't set up yet. Try your email instead.",
        ),
      );
    }
    return fetch('https://api.brevo.com/v3/transactionalSMS/sms', {
      method: 'POST',
      headers: this.headers(),
      body: JSON.stringify({
        sender: this.brevo.smsSender,
        recipient: destination.replace(/\D/g, ''),
        content,
        type: 'transactional',
      }),
    });
  }

  private headers(): Record<string, string> {
    return {
      'api-key': this.brevo.apiKey,
      accept: 'application/json',
      'content-type': 'application/json',
    };
  }
}

export function createVerificationDelivery(brevo: BrevoConfig | null): VerificationDelivery {
  if (!brevo) {
    return new UnconfiguredVerificationDelivery();
  }
  return new BrevoDelivery(brevo);
}
