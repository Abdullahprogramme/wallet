import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

export interface AuthRequest extends Request {
    user?: string;
}

export const auth = (req: AuthRequest, res: Response, next: NextFunction) => {
    const token = req.header("Authorization");

    if (!token) return res.status(401).json({ msg: "No token provided" });

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET!) as { userId: string };
        req.user = decoded.userId;
        next();
    } catch {
        res.status(401).json({ msg: "Invalid token" });
    }
};
