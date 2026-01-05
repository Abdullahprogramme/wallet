import { Request, Response } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/User";

export const register = async (req: Request, res: Response) => {
    try {
        const { name, email, password } = req.body;

        let user = await User.findOne({ email });
        if (user) return res.status(400).json({ msg: "User already exists" });

        const hashed = await bcrypt.hash(password, 8);

        user = await User.create({ name, email, password: hashed });

        const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET!);

        res.json({ token });
    } catch (err) {
        res.status(500).json({ error: "Server error" });
    }
};

export const login = async (req: Request, res: Response) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email });
        if (!user) return res.status(400).json({ msg: "Invalid credentials" });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ msg: "Invalid credentials" });

        const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET!);

        res.json({ token });
    } catch (err) {
        res.status(500).json({ error: "Server error" });
    }
};

export const updatePassword = async (req: Request, res: Response) => {
    try {
        const { userId } = req.params;
        const { oldPassword, newPassword } = req.body;
        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ msg: "User not found" });

        const isMatch = await bcrypt.compare(oldPassword, user.password);
        if (!isMatch) return res.status(400).json({ msg: "Old password is incorrect" });

        const hashed = await bcrypt.hash(newPassword, 8);
        user.password = hashed;
        
        await user.save();
        res.json({ msg: "Password updated successfully" });
    } catch (err) {
        res.status(500).json({ error: "Server error" });
    }
};
